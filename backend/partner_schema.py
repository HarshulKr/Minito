import mysql.connector

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="password",
        database="minito_db"
    )
    cursor = conn.cursor()

    try:
        cursor.execute("ALTER TABLE deliverypartner ADD COLUMN WalletBalance DECIMAL(10,2) DEFAULT 0.00;")
        print("WalletBalance added to deliverypartner.")
    except Exception as e:
        print("WalletBalance exists or error: ", e)

    try:
        cursor.execute("ALTER TABLE orders ADD COLUMN CommissionEarned DECIMAL(10,2) DEFAULT 0.00;")
        print("CommissionEarned added to orders.")
    except Exception as e:
        print("CommissionEarned exists or error: ", e)

    conn.commit()
    conn.close()

except Exception as main_e:
    print("DB Connection Error: ", main_e)
