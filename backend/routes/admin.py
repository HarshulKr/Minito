from flask import Blueprint, request, jsonify
from db import get_db

admin = Blueprint("admin", __name__)

@admin.route("/store-health", methods=["GET"])
def store_health():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT d.StoreID, d.StoreLocation as StoreName, 
               COALESCE(SUM(o.TotalBillAmount), 0) as TotalRevenue,
               (SELECT COUNT(*) FROM employee e WHERE e.StoreID = d.StoreID) as ActiveEmployees
        FROM darkstore d
        LEFT JOIN orders o ON d.StoreID = o.StoreID
        GROUP BY d.StoreID, d.StoreLocation
    """)
    return jsonify(cursor.fetchall())

@admin.route("/analytics", methods=["GET"])
def get_analytics():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT SUM(TotalBillAmount) as TotalRevenue FROM orders")
    revenue = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as TotalOrders FROM orders")
    orders = cursor.fetchone()
    
    cursor.execute("SELECT COUNT(*) as TotalCustomers FROM customer")
    customers = cursor.fetchone()

    return jsonify({
        "revenue": revenue["TotalRevenue"] or 0,
        "orders": orders["TotalOrders"],
        "customers": customers["TotalCustomers"]
    })

@admin.route("/users", methods=["GET"])
def get_users():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT CustomerID as ID, Name, Email, PhoneNumber, Address, 'customer' as Role FROM customer")
    customers = cursor.fetchall()
    
    cursor.execute("SELECT ManagerID as ID, Name, Email, '' as PhoneNumber, '' as Address, 'Store Manager' as Role FROM storemanager")
    managers = cursor.fetchall()
    
    cursor.execute("SELECT PartnerID as ID, Name, Email, PhoneNumber, VehicleDetails as Address, 'Delivery Partner' as Role FROM deliverypartner")
    partners = cursor.fetchall()

    return jsonify(customers + managers + partners)

@admin.route("/users/<role>", methods=["POST"])
def add_user(role):
    data = request.json
    db = get_db()
    cursor = db.cursor()
    
    email = data.get("Email")
    
    # Validation against dupes across customer and storemanager 
    if role in ["customer", "Store Manager"]:
        cursor.execute("SELECT Email FROM customer WHERE Email=%s UNION SELECT Email FROM storemanager WHERE Email=%s", (email, email))
        if cursor.fetchone():
            return jsonify({"error": "Email already exists"}), 400

    try:
        if role == 'customer':
            cursor.execute("INSERT INTO customer (Name, Email, PhoneNumber, Address, WalletBalance) VALUES (%s, %s, %s, %s, %s)", 
                           (data.get("Name"), email, data.get("PhoneNumber"), data.get("Address"), 5000.00))
        elif role == 'Store Manager':
            cursor.execute("INSERT INTO storemanager (Name, Email, StoreID, WalletBalance) VALUES (%s, %s, %s, %s)", 
                           (data.get("Name"), email, data.get("StoreID"), 0.00))
        elif role == 'Delivery Partner':
            cursor.execute("INSERT INTO deliverypartner (Name, Email, PhoneNumber, VehicleDetails) VALUES (%s, %s, %s, %s)", 
                           (data.get("Name"), email, data.get("PhoneNumber"), data.get("VehicleDetails")))
        else:
            return jsonify({"error": "Invalid Role"}), 400
        db.commit()
        return jsonify({"message": "User added"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/users/<role>/<int:uid>", methods=["DELETE"])
def delete_user(role, uid):
    db = get_db()
    cursor = db.cursor()
    try:
        if role == 'customer':
             # Clean up constraints
             cursor.execute("DELETE FROM wallettransfers WHERE CustomerID=%s", (uid,))
             cursor.execute("DELETE FROM custombaskets WHERE CustomerID=%s", (uid,))
             cursor.execute("DELETE FROM payment WHERE OrderID IN (SELECT OrderID FROM orders WHERE CustomerID=%s)", (uid,))
             cursor.execute("DELETE FROM orderitem WHERE OrderID IN (SELECT OrderID FROM orders WHERE CustomerID=%s)", (uid,))
             cursor.execute("DELETE FROM orders WHERE CustomerID=%s", (uid,))
             cursor.execute("DELETE FROM cart WHERE CustomerID=%s", (uid,))
             cursor.execute("DELETE FROM userbasketitems WHERE BasketID IN (SELECT BasketID FROM userbaskets WHERE CustomerID=%s)", (uid,))
             cursor.execute("DELETE FROM userbaskets WHERE CustomerID=%s", (uid,))
             cursor.execute("DELETE FROM customer WHERE CustomerID=%s", (uid,))
        elif role == 'Store Manager':
             cursor.execute("DELETE FROM wallettransfers WHERE ManagerID=%s", (uid,))
             cursor.execute("DELETE FROM storemanager WHERE ManagerID=%s", (uid,))
        elif role == 'Delivery Partner':
             cursor.execute("DELETE FROM deliverypartner WHERE PartnerID=%s", (uid,))
        else:
             return jsonify({"error": "Invalid Role"}), 400
        db.commit()
        return jsonify({"message": "User deleted"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@admin.route("/products", methods=["GET"])
def get_products():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM products")
    return jsonify(cursor.fetchall())

@admin.route("/products", methods=["POST"])
def add_product():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("INSERT INTO products (ProductName, Brand, Price, CategoryID) VALUES (%s, %s, %s, %s)",
                       (data["ProductName"], data.get("Brand", ""), data["Price"], data.get("CategoryID", 1)))
        
        product_id = cursor.lastrowid
        
        # Link mapped stores automatically
        store_ids = data.get("StoreIDs", [])
        initial_qty = data.get("InitialQuantity", 0)
        
        if store_ids:
            for sid in store_ids:
                 cursor.execute("INSERT INTO storeinventory (StoreID, ProductID, Quantity) VALUES (%s, %s, %s)", 
                                (sid, product_id, initial_qty))
        
        db.commit()
        return jsonify({"message": "Product mapped and added successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/products/<int:pid>", methods=["PUT"])
def update_product(pid):
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("UPDATE products SET ProductName=%s, Brand=%s, Price=%s, CategoryID=%s WHERE ProductID=%s",
                       (data["ProductName"], data.get("Brand", ""), data["Price"], data.get("CategoryID", 1), pid))
        db.commit()
        return jsonify({"message": "Product updated successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/products/<int:pid>", methods=["DELETE"])
def delete_product(pid):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM orderitem WHERE ProductID=%s", (pid,))
        cursor.execute("DELETE FROM cart WHERE ProductID=%s", (pid,))
        cursor.execute("DELETE FROM storeinventory WHERE ProductID=%s", (pid,))
        cursor.execute("DELETE FROM comboitems WHERE ProductID=%s", (pid,))
        cursor.execute("DELETE FROM userbasketitems WHERE ProductID=%s", (pid,))
        cursor.execute("DELETE FROM products WHERE ProductID=%s", (pid,))
        db.commit()
        return jsonify({"message": "Product deleted successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/employees", methods=["GET"])
def get_employees():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT e.EmployeeID, e.Name, e.Role, d.StoreLocation 
        FROM employee e
        LEFT JOIN darkstore d ON e.StoreID = d.StoreID
    """)
    return jsonify(cursor.fetchall())

@admin.route("/employees", methods=["POST"])
def add_employee():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("INSERT INTO employee (Name, Role, StoreID) VALUES (%s, %s, %s)",
                       (data["Name"], data["Role"], data["StoreID"]))
        db.commit()
        return jsonify({"message": "Employee added"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/employees/<int:eid>", methods=["DELETE"])
def delete_employee(eid):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM employee WHERE EmployeeID=%s", (eid,))
        db.commit()
        return jsonify({"message": "Employee deleted"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/darkstores", methods=["GET"])
def get_darkstores():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM darkstore")
    return jsonify(cursor.fetchall())

@admin.route("/darkstores", methods=["POST"])
def add_darkstore():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("INSERT INTO darkstore (StoreLocation) VALUES (%s)", (data["StoreLocation"],))
        db.commit()
        return jsonify({"message": "Store created"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/darkstores/<int:did>", methods=["DELETE"])
def delete_darkstore(did):
    db = get_db()
    cursor = db.cursor()
    try:
        # Constraints clean up
        cursor.execute("DELETE FROM storeinventory WHERE StoreID=%s", (did,))
        cursor.execute("DELETE FROM employee WHERE StoreID=%s", (did,))
        cursor.execute("DELETE FROM storemanager WHERE StoreID=%s", (did,))
        cursor.execute("DELETE FROM darkstore WHERE StoreID=%s", (did,))
        db.commit()
        return jsonify({"message": "Store deleted"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@admin.route("/audit-log", methods=["GET"])
def get_audit_log():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT w.TransferID, w.Amount, w.TransferDate, w.OrderID,
               c.Name as CustomerName, m.Name as ManagerName
        FROM wallettransfers w
        LEFT JOIN customer c ON w.CustomerID = c.CustomerID
        LEFT JOIN storemanager m ON w.ManagerID = m.ManagerID
        ORDER BY w.TransferDate DESC
    """)
    return jsonify(cursor.fetchall())
