from flask import Blueprint, request, jsonify
from db import get_db

auth = Blueprint("auth", __name__)

@auth.route("/login", methods=["POST"])
def login():
    data = request.json
    role = data.get("role")
    email = data.get("email")

    db = get_db()
    cursor = db.cursor(dictionary=True)

    table_map = {
        "Customer": "customer",
        "Admin": "admin",
        "Store Manager": "storemanager",
        "Delivery Partner": "deliverypartner"
    }
    
    if role not in table_map:
        return {"error": "Invalid Role"}, 400

    cursor.execute(f"SELECT * FROM {table_map[role]} WHERE Email=%s", (email,))
    user = cursor.fetchone()

    if user:
        user["Role"] = role
        # Cast Decimal wallet to string for JSON serialization compatibility
        if 'WalletBalance' in user and user['WalletBalance'] is not None:
             user['WalletBalance'] = str(user['WalletBalance'])
        return jsonify(user)

    return {"error": "User not found"}, 404