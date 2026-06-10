from flask import Blueprint, request, jsonify
from db import get_db

customer = Blueprint("customer", __name__)


@customer.route("/products", methods=["GET"])
def get_products():
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT 
            p.ProductID,
            p.ProductName,
            p.Price,
            p.CategoryID,
            p.is_flash_sale,
            p.original_price
        FROM products p
    """)

    return jsonify(cursor.fetchall())

@customer.route("/cart/add", methods=["POST"])
def add_cart():
    data = request.json
    db = get_db()
    cursor = db.cursor()

    cursor.execute(
        "INSERT INTO cart VALUES (%s,%s,%s)",
        (data["customer_id"], data["product_id"], data["qty"])
    )
    db.commit()

    return {"message": "Added to cart"}

@customer.route("/cart/<int:cid>")
def view_cart(cid):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
  SELECT 
    p.ProductID,
    p.ProductName,
    p.Price,
    c.Quantity
FROM cart c
JOIN products p ON c.ProductID = p.ProductID
WHERE c.CustomerID = %s
    """,(cid,))

    return jsonify(cursor.fetchall())

@customer.route("/cart/update", methods=["POST"])
def update_cart():
    data = request.json
    db = get_db()
    cursor = db.cursor()

    cursor.execute("""
        UPDATE cart
        SET Quantity = %s
        WHERE CustomerID = %s AND ProductID = %s
    """, (data["qty"], data["customer_id"], data["product_id"]))

    db.commit()
    return {"message": "Updated"}

@customer.route("/cart/remove", methods=["POST"])
def remove_cart():
    data = request.json

    db = get_db()
    cursor = db.cursor()

    try:
        cursor.execute("""
            DELETE FROM cart
            WHERE CustomerID = %s AND ProductID = %s
        """, (data["customer_id"], data["product_id"]))

        db.commit()
        return {"message": "Removed"}

    except Exception as e:
        print("ERROR:", e)
        return {"error": "Failed"}, 500

@customer.route("/recommendations/<int:cid>")
def get_recommendations(cid):
    category_id = request.args.get("category_id")
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    query = """
        SELECT p.ProductID, p.ProductName, p.Price, p.CategoryID, COUNT(oi.ProductID) as freq
        FROM orderitem oi
        JOIN orders o ON oi.OrderID = o.OrderID
        JOIN products p ON oi.ProductID = p.ProductID
        WHERE o.CustomerID = %s
    """
    params = [cid]
    
    if category_id and category_id != 'All':
        cat_map = {'Grocery': 1, 'Pharmaceutical': 2, 'Electronics': 3}
        cat = cat_map.get(category_id)
        if cat:
            query += " AND p.CategoryID = %s"
            params.append(cat)
            
    query += """
        GROUP BY p.ProductID, p.ProductName, p.Price, p.CategoryID
        ORDER BY freq DESC
        LIMIT 5
    """
    cursor.execute(query, tuple(params))
    recommendations = cursor.fetchall()
    
    if not recommendations:
        return get_trending_logic(category_id, limit=5)

    return jsonify(recommendations)

def get_trending_logic(category_id, limit=10):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    query = """
        SELECT p.ProductID, p.ProductName, p.Price, p.CategoryID, SUM(oi.QuantityOrdered) as total_qty
        FROM orderitem oi
        JOIN products p ON oi.ProductID = p.ProductID
    """
    params = []
    
    if category_id and category_id != 'All':
        cat_map = {'Grocery': 1, 'Pharmaceutical': 2, 'Electronics': 3}
        cat = cat_map.get(category_id)
        if cat:
            query += " WHERE p.CategoryID = %s"
            params.append(cat)
            
    query += f"""
        GROUP BY p.ProductID, p.ProductName, p.Price, p.CategoryID
        ORDER BY total_qty DESC
        LIMIT {limit}
    """
    cursor.execute(query, tuple(params))
    return jsonify(cursor.fetchall())

@customer.route("/trending")
def get_trending():
    category_id = request.args.get("category_id")
    return get_trending_logic(category_id)

@customer.route("/combos")
def get_combos():
    category_id = request.args.get("category_id")
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    query = "SELECT * FROM combos"
    params = []
    
    if category_id and category_id != 'All':
        cat_map = {'Grocery': 1, 'Pharmaceutical': 2, 'Electronics': 3}
        cat = cat_map.get(category_id)
        if cat:
            query += " WHERE CategoryID = %s"
            params.append(cat)
            
    cursor.execute(query, tuple(params))
    combos = cursor.fetchall()
    for c in combos:
        cursor.execute("""
            SELECT p.ProductID, p.ProductName, p.Price 
            FROM comboitems ci 
            JOIN products p ON ci.ProductID = p.ProductID 
            WHERE ci.ComboID = %s
        """, (c['ComboID'],))
        c['items'] = cursor.fetchall()
    return jsonify(combos)

import json
@customer.route("/custombaskets/save", methods=["POST"])
def save_custom_basket():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("INSERT INTO custombaskets (CustomerID, BasketName, ProductIDs) VALUES (%s, %s, %s)", 
                       (data['customer_id'], data['basket_name'], json.dumps(data['product_ids'])))
        db.commit()
        return jsonify({"message": "Custom Basket saved successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@customer.route("/custombaskets/<int:cid>")
def get_custom_baskets(cid):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM custombaskets WHERE CustomerID = %s", (cid,))
    baskets = cursor.fetchall()
    for b in baskets:
        pids = json.loads(b['ProductIDs'])
        if pids:
            format_strings = ','.join(['%s'] * len(pids))
            cursor.execute(f"SELECT ProductID, ProductName, Price FROM products WHERE ProductID IN ({format_strings})", tuple(pids))
            b['items'] = cursor.fetchall()
        else:
            b['items'] = []
    return jsonify(baskets)

@customer.route("/wallet/<int:cid>")
def get_wallet(cid):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT WalletBalance FROM customer WHERE CustomerID = %s", (cid,))
    customer = cursor.fetchone()
    if customer:
        return jsonify({"WalletBalance": str(customer['WalletBalance'])})
    return jsonify({"error": "Not Found"}), 404

@customer.route("/wallet/add", methods=["POST"])
def add_wallet_money():
    data = request.json
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("UPDATE customer SET WalletBalance = WalletBalance + %s WHERE CustomerID = %s", 
                       (data['amount'], data['customer_id']))
        db.commit()
        return jsonify({"message": "Wallet Recharge Successful!"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@customer.route("/cart/check-stock/<int:cid>", methods=["GET"])
def check_cart_stock(cid):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    # Get current cart
    cursor.execute("""
        SELECT c.ProductID, c.Quantity, p.ProductName 
        FROM cart c
        JOIN products p ON c.ProductID = p.ProductID
        WHERE c.CustomerID = %s
    """, (cid,))
    cart_items = cursor.fetchall()
    
    removed_items = []
    for item in cart_items:
        # Check if any store has enough stock
        cursor.execute("""
            SELECT storeid 
            FROM storeinventory 
            WHERE productid = %s AND Quantity >= %s
            LIMIT 1
        """, (item['ProductID'], item['Quantity']))
        
        if not cursor.fetchone():
            # Out of stock everywhere!
            removed_items.append(item['ProductName'])
            cursor.execute("DELETE FROM cart WHERE CustomerID = %s AND ProductID = %s", (cid, item['ProductID']))
            
    if removed_items:
        db.commit()
        
    return jsonify({"removed": removed_items})