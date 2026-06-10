from flask import Blueprint, request, jsonify
from db import get_db

delivery = Blueprint("delivery", __name__)

@delivery.route("/orders/<int:partner_id>", methods=["GET"])
def get_orders(partner_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT o.*, c.Name as CustomerName, c.Address, c.PhoneNumber
        FROM orders o
        JOIN customer c ON o.CustomerID = c.CustomerID
        WHERE o.DeliveryPartnerID = %s AND o.OrderStatus IN ('Placed', 'Packed', 'Picked', 'Out for Delivery')
        ORDER BY o.OrderDateTime ASC
    """, (partner_id,))
    orders = cursor.fetchall()
    
    for order in orders:
        cursor.execute("""
            SELECT p.ProductName, oi.QuantityOrdered
            FROM orderitem oi
            JOIN products p ON oi.ProductID = p.ProductID
            WHERE oi.OrderID = %s
        """, (order["OrderID"],))
        order["items"] = cursor.fetchall()

    return jsonify(orders)

@delivery.route("/available-orders/<int:store_id>", methods=["GET"])
def get_available_orders(store_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT o.*, c.Name as CustomerName, c.Address, c.PhoneNumber
        FROM orders o
        JOIN customer c ON o.CustomerID = c.CustomerID
        WHERE o.StoreID = %s AND o.DeliveryPartnerID IS NULL AND o.OrderStatus = 'Packed'
        ORDER BY o.OrderDateTime ASC
    """, (store_id,))
    return jsonify(cursor.fetchall())

@delivery.route("/accept-order", methods=["POST"])
def accept_order():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT is_available FROM deliverypartner WHERE partnerid = %s FOR UPDATE", (data["partner_id"],))
        p_res = cursor.fetchone()
        if not p_res or not p_res[0]:
            return jsonify({"error": "Partner is currently unavailable"}), 403

        cursor.execute("SELECT DeliveryPartnerID FROM orders WHERE OrderID = %s FOR UPDATE", (data["order_id"],))
        o_res = cursor.fetchone()
        
        if not o_res:
            return jsonify({"error": "Order not found"}), 404
        if o_res[0] is not None:
            return jsonify({"error": "Order already claimed by another partner!"}), 409
            
        cursor.execute("""
            UPDATE orders 
            SET DeliveryPartnerID = %s, OrderStatus = 'Picked' 
            WHERE OrderID = %s
        """, (data["partner_id"], data["order_id"]))
            
        cursor.execute("UPDATE deliverypartner SET is_available = 0 WHERE partnerid = %s", (data["partner_id"],))
        
        db.commit()
        return jsonify({"message": "Order claimed successfully"})
    except Exception as e:
        db.rollback()
        return jsonify({"error": str(e)}), 500

@delivery.route("/earnings/<int:partner_id>", methods=["GET"])
def get_earnings(partner_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT COUNT(*) as completed_orders
        FROM orders 
        WHERE DeliveryPartnerID = %s AND OrderStatus = 'Delivered' AND DATE(OrderDateTime) = CURDATE()
    """, (partner_id,))
    data_completed = cursor.fetchone()
    completed = data_completed['completed_orders'] if data_completed else 0

    cursor.execute("""
        SELECT SUM(CommissionEarned) as todays_earnings
        FROM orders
        WHERE DeliveryPartnerID = %s AND OrderStatus = 'Delivered' AND DATE(OrderDateTime) = CURDATE()
    """, (partner_id,))
    data_today = cursor.fetchone()
    earnings = data_today['todays_earnings'] if data_today and data_today['todays_earnings'] else 0
    
    cursor.execute("SELECT WalletBalance FROM deliverypartner WHERE partnerid = %s", (partner_id,))
    total_data = cursor.fetchone()
    total_wallet = float(total_data['WalletBalance']) if total_data and total_data['WalletBalance'] else 0.0

    cursor.execute("""
        SELECT OrderID, OrderDateTime, CommissionEarned
        FROM orders
        WHERE DeliveryPartnerID = %s AND OrderStatus = 'Delivered'
        ORDER BY OrderDateTime DESC LIMIT 10
    """, (partner_id,))
    history = cursor.fetchall()
    
    return jsonify({
        "earnings": float(earnings), 
        "completed": completed, 
        "total_wallet": float(total_wallet),
        "history": history
    })


@delivery.route("/orders/update", methods=["POST"])
def update_order_status():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        new_status = data["status"]
        order_id = data["order_id"]
        
        if new_status == "Delivered":
            cursor.execute("SELECT DeliveryPartnerID, CommissionEarned FROM orders WHERE OrderID = %s FOR UPDATE", (order_id,))
            o_res = cursor.fetchone()
            if o_res:
                p_id = o_res[0]
                comm = float(o_res[1] or 0.0)
                
                cursor.execute("UPDATE orders SET OrderStatus = 'Delivered' WHERE OrderID = %s", (order_id,))
                
                if comm == 0:
                    cursor.execute("UPDATE orders SET CommissionEarned = 50 WHERE OrderID = %s", (order_id,))
                    if p_id:
                        cursor.execute("UPDATE deliverypartner SET WalletBalance = WalletBalance + 50, is_available = 1 WHERE partnerid = %s", (p_id,))
        else:
            cursor.execute("UPDATE orders SET OrderStatus = %s WHERE OrderID = %s", (new_status, order_id))
            
        db.commit()
        return jsonify({"message": "Order status updated"})
    except Exception as e:
        db.rollback()
        return jsonify({"error": str(e)}), 500
