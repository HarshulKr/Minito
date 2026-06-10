from flask import Blueprint, request, jsonify
from db import get_db

manager = Blueprint("manager", __name__)

@manager.route("/inventory/<int:store_id>", methods=["GET"])
def low_stock_alerts(store_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT p.ProductName, si.Quantity, si.ProductID 
        FROM storeinventory si
        JOIN products p ON si.ProductID = p.ProductID
        WHERE si.StoreID = %s AND si.Quantity < 5
    """, (store_id,))
    return jsonify(cursor.fetchall())

@manager.route("/orders/<int:store_id>", methods=["GET"])
def get_orders(store_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM orders WHERE StoreID = %s ORDER BY OrderDateTime DESC", (store_id,))
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

@manager.route("/orders/update", methods=["POST"])
def update_order_status():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        if data.get("partner_id"):
            cursor.execute("SELECT DeliveryPartnerID FROM orders WHERE OrderID = %s FOR UPDATE", (data["order_id"],))
            old_p = cursor.fetchone()
            if old_p and old_p[0] and old_p[0] != data["partner_id"]:
                cursor.execute("UPDATE deliverypartner SET is_available = 1 WHERE partnerid = %s", (old_p[0],))
                
            cursor.execute("UPDATE orders SET OrderStatus = %s, DeliveryPartnerID = %s WHERE OrderID = %s", 
                           (data["status"], data["partner_id"], data["order_id"]))
            cursor.execute("UPDATE deliverypartner SET is_available = 0 WHERE partnerid = %s", (data["partner_id"],))
        else:
            cursor.execute("UPDATE orders SET OrderStatus = %s WHERE OrderID = %s", (data["status"], data["order_id"]))
            
        if data["status"] == "Delivered":
            cursor.execute("SELECT DeliveryPartnerID FROM orders WHERE OrderID = %s FOR UPDATE", (data["order_id"],))
            p_res = cursor.fetchone()
            if p_res and p_res[0]:
                cursor.execute("UPDATE deliverypartner SET is_available = 1 WHERE partnerid = %s", (p_res[0],))

        db.commit()
        return jsonify({"message": "Order status updated"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@manager.route("/partners/<int:store_id>", methods=["GET"])
def get_partners(store_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT partnerid, Name, VehicleDetails, is_available FROM deliverypartner WHERE storeid = %s", (store_id,))
    return jsonify(cursor.fetchall())

@manager.route("/employees/<int:store_id>", methods=["GET"])
def get_employees(store_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM employee WHERE StoreID = %s", (store_id,))
    return jsonify(cursor.fetchall())

@manager.route("/employees", methods=["POST"])
def add_employee():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("INSERT INTO employee (Name, Role, StoreID) VALUES (%s, %s, %s)", 
                       (data["Name"], data["Role"], data["StoreID"]))
        db.commit()
        return jsonify({"message": "employee added"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@manager.route("/employees/<int:employee_id>", methods=["DELETE"])
def delete_employee(employee_id):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM employee WHERE EmployeeID = %s", (employee_id,))
        db.commit()
        return jsonify({"message": "employee removed"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@manager.route("/inventory/restock", methods=["POST"])
def restock_inventory():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("""
            UPDATE storeinventory 
            SET Quantity = Quantity + %s 
            WHERE StoreID = %s AND ProductID = %s
        """, (data["quantity_added"], data["store_id"], data["product_id"]))
        db.commit()
        return jsonify({"message": "Restocked successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@manager.route("/inventory/full/<int:store_id>", methods=["GET"])
def get_full_inventory(store_id):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT 
            p.ProductID, 
            p.ProductName, 
            p.Price, 
            p.expiry_date,
            p.is_flash_sale,
            p.original_price,
            c.CategoryName,
            si.Quantity as QuantityRemaining
        FROM storeinventory si
        JOIN products p ON si.ProductID = p.ProductID
        LEFT JOIN category c ON p.CategoryID = c.CategoryID
        WHERE si.StoreID = %s
    """, (store_id,))
    return jsonify(cursor.fetchall())

@manager.route("/create-expiry-combo", methods=["POST"])
def create_expiry_combo():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        # data: { combo_name: "Special Flash Deal...", product_ids: [1,2,3], category_id: 1 (optional) }
        category_id = data.get("category_id", 1)  # Defaulting or passed
        cursor.execute("INSERT INTO combos (ComboName, CategoryID) VALUES (%s, %s)", 
                       (data["combo_name"], category_id))
        combo_id = cursor.lastrowid
        
        for pid in data["product_ids"]:
            cursor.execute("INSERT INTO comboitems (ComboID, ProductID) VALUES (%s, %s)", 
                           (combo_id, pid))
                           
        db.commit()
        return jsonify({"message": "Combo created successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@manager.route("/dispose-restock", methods=["POST"])
def dispose_restock():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        # We replace the local quantity with the new quantity and set a new expiry date globally
        cursor.execute("""
            UPDATE storeinventory 
            SET Quantity = %s 
            WHERE StoreID = %s AND ProductID = %s
        """, (data["new_quantity"], data["store_id"], data["product_id"]))
        
        cursor.execute("""
            UPDATE products 
            SET expiry_date = %s 
            WHERE ProductID = %s
        """, (data["new_expiry_date"], data["product_id"]))
        
        db.commit()
        return jsonify({"message": "Disposed and restocked successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@manager.route("/flash-sale", methods=["POST"])
def flash_sale():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("""
            UPDATE products 
            SET original_price = Price, Price = ROUND(Price * 0.5, 2), is_flash_sale = 1
            WHERE ProductID = %s AND (is_flash_sale = 0 OR is_flash_sale IS NULL)
        """, (data["product_id"],))
        if cursor.rowcount == 0:
            return jsonify({"error": "Product is already undergoing a flash sale!"}), 400
        db.commit()
        return jsonify({"message": "Flash sale launched"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
