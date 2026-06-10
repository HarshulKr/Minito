from flask import Blueprint, request, jsonify
from db import get_db
import json

order = Blueprint("order", __name__)

@order.route("/create", methods=["POST"])
def create_order():
    data = request.json
    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        store_groups = {}
        unfulfilled = []
        fulfilled_ids = []
        chargeable_total = 0.0

        for req_item in data["items"]:
            cursor.execute("SELECT Price FROM products WHERE ProductID = %s", (req_item["product_id"],))
            p_res = cursor.fetchone()
            if not p_res: continue
            
            unit_price = float(p_res["Price"])
            req_qty = int(req_item["qty"])
            
            cursor.execute("""
                SELECT storeid 
                FROM storeinventory 
                WHERE productid = %s AND Quantity >= %s
                LIMIT 1
            """, (req_item["product_id"], req_qty))
            loc_res = cursor.fetchone()
            
            if loc_res:
                s_id = loc_res["storeid"]
                if s_id not in store_groups:
                    store_groups[s_id] = {"items": [], "subtotal": 0.0}
                
                cost = unit_price * req_qty
                store_groups[s_id]["items"].append(req_item)
                store_groups[s_id]["subtotal"] += cost
                chargeable_total += cost
                fulfilled_ids.append(req_item["product_id"])
            else:
                unfulfilled.append(req_item["product_id"])
                cursor.execute("DELETE FROM cart WHERE CustomerID = %s AND ProductID = %s", 
                               (data["customer_id"], req_item["product_id"]))
                

        cursor.execute("SELECT WalletBalance FROM customer WHERE CustomerID = %s", (data["customer_id"],))
        customer = cursor.fetchone()
        if not customer or float(customer["WalletBalance"]) < chargeable_total:
            return jsonify({"error": "Insufficient Wallet Balance to fulfill capable items."}), 400
            
        if chargeable_total == 0:
            db.commit()
            return jsonify({
                "error": "The items in your cart went out of stock and have been removed.",
                "unfulfilled": unfulfilled
            }), 400
            
        calculated_split_total = sum(group["subtotal"] for group in store_groups.values())
        if abs(calculated_split_total - chargeable_total) > 0.01:
            raise Exception("Financial reconciliation failed: Split total mismatches deduction amount.")
        
        cursor.execute("UPDATE customer SET WalletBalance = WalletBalance - %s WHERE CustomerID = %s", 
                       (chargeable_total, data["customer_id"]))
                       
        created_orders = []

        for s_id, group in store_groups.items():
            sub = group["subtotal"]
            
            cursor.execute("SELECT partnerid FROM deliverypartner WHERE storeid = %s AND is_available = 1 LIMIT 1", (s_id,))
            part_res = cursor.fetchone()
            p_id = part_res["partnerid"] if part_res else None
            
            if p_id:
                cursor.execute("UPDATE deliverypartner SET is_available = 0 WHERE partnerid = %s", (p_id,))
                
            cursor.execute("SELECT ManagerID FROM storemanager WHERE StoreID = %s LIMIT 1", (s_id,))
            mgr_res = cursor.fetchone()
            m_id = mgr_res["ManagerID"] if mgr_res else None
            
            if m_id:
                cursor.execute("UPDATE storemanager SET WalletBalance = WalletBalance + %s WHERE ManagerID = %s", (sub, m_id))
                
            cursor.execute("""
                INSERT INTO orders (OrderDateTime, OrderStatus, TotalBillAmount, CustomerID, StoreID, DeliveryPartnerID)
                VALUES (NOW(),'Placed',%s,%s,%s,%s)
            """, (sub, data["customer_id"], s_id, p_id))
            o_id = cursor.lastrowid
            created_orders.append(o_id)
            
            if m_id:
                cursor.execute("""
                    INSERT INTO wallettransfers (CustomerID, ManagerID, Amount, TransferDate, OrderID) 
                    VALUES (%s, %s, %s, NOW(), %s)
                """, (data["customer_id"], m_id, sub, o_id))
                
            for item in group["items"]:
                cursor.execute("""
                    INSERT INTO orderitem (OrderID, ProductID, QuantityOrdered)
                    VALUES (%s,%s,%s)
                """,(o_id, item["product_id"], item["qty"]))

                cursor.execute("""
                    UPDATE storeinventory 
                    SET Quantity = Quantity - %s
                    WHERE StoreID = %s AND ProductID = %s AND Quantity >= %s
                """, (item["qty"], s_id, item["product_id"], item["qty"]))
                
                if cursor.rowcount == 0:
                    cursor.execute("ROLLBACK")
                    return jsonify({"error": "Item stock changed during checkout. Please try again."}), 400
                

                cursor.execute("DELETE FROM cart WHERE CustomerID = %s AND ProductID = %s", 
                               (data["customer_id"], item["product_id"]))

        db.commit()
        return jsonify({
            "message": "Order processed successfully!",
            "orders": created_orders, 
            "unfulfilled": unfulfilled
        })

    except Exception as e:
        db.rollback()
        print("ORDER SPLIT ERROR:", e)
        return jsonify({"error": str(e)}), 500


@order.route("/cancel", methods=["POST"])
def cancel_order():
    data = request.json
    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:

        cursor.execute("SELECT * FROM orders WHERE OrderID=%s AND OrderStatus='Placed' FOR UPDATE", (data['order_id'],))
        order_data = cursor.fetchone()
        
        if not order_data:
            return jsonify({"error": "Order cannot be cancelled"}), 400
            
        total = order_data["TotalBillAmount"]
        customer_id = order_data["CustomerID"]
        store_id = order_data["StoreID"]
        
        cursor.execute("SELECT ManagerID FROM storemanager WHERE StoreID = %s LIMIT 1", (store_id,))
        manager_res = cursor.fetchone()
        manager_id = manager_res["ManagerID"] if manager_res else None

        cursor.execute("UPDATE customer SET WalletBalance = WalletBalance + %s WHERE CustomerID = %s", (total, customer_id))
    
        if manager_id:
            cursor.execute("UPDATE storemanager SET WalletBalance = WalletBalance - %s WHERE ManagerID = %s", (total, manager_id))
            
        if manager_id:
            cursor.execute("""
                INSERT INTO wallettransfers (CustomerID, ManagerID, Amount, TransferDate, OrderID) 
                VALUES (%s, %s, %s, NOW(), %s)
            """, (customer_id, manager_id, -float(total), data['order_id']))
            

        cursor.execute("UPDATE orders SET OrderStatus='Cancelled' WHERE OrderID=%s", (data['order_id'],))
        
        cursor.execute("SELECT ProductID, QuantityOrdered FROM orderitem WHERE OrderID = %s", (data['order_id'],))
        items = cursor.fetchall()
        for item in items:
            cursor.execute("""
                UPDATE storeinventory
                SET Quantity = Quantity + %s
                WHERE StoreID = %s AND ProductID = %s
            """, (item['QuantityOrdered'], store_id, item['ProductID']))
        
        if order_data.get("DeliveryPartnerID"):
            cursor.execute("UPDATE deliverypartner SET is_available = 1 WHERE partnerid = %s", (order_data["DeliveryPartnerID"],))
        
        db.commit()
        return jsonify({"message": "Order Cancelled and Wallet Refunded"})
    except Exception as e:
        db.rollback()
        print("CANCEL ERROR:", e)
        return jsonify({"error": str(e)}), 500

@order.route("/history/<int:customer_id>", methods=["GET"])
def order_history(customer_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT o.*, d.StoreLocation 
        FROM orders o
        JOIN darkstore d ON o.StoreID = d.StoreID
        WHERE o.CustomerID = %s
        ORDER BY o.OrderDateTime DESC
    """, (customer_id,))
    
    orders = cursor.fetchall()

    for order_details in orders:
        cursor.execute("""
            SELECT p.ProductName, oi.QuantityOrdered
            FROM orderitem oi
            JOIN products p ON oi.ProductID = p.ProductID
            WHERE oi.OrderID = %s
        """, (order_details["OrderID"],))
        
        order_details["items"] = cursor.fetchall()

    return jsonify(orders)