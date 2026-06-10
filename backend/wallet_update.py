import mysql.connector

def wallet_update():
    try:
        db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="hansika",
            database="minito_db"
        )
        cursor = db.cursor()

        try:
            cursor.execute("ALTER TABLE customer ADD COLUMN WalletBalance DECIMAL(10,2) DEFAULT 5000.00")
            cursor.execute("UPDATE customer SET WalletBalance = 5000.00")
        except mysql.connector.Error as err:
            if err.errno == 1060: # column exists
                pass
            else:
                print("Error altering customer:", err)

        try:
            cursor.execute("ALTER TABLE storemanager ADD COLUMN WalletBalance DECIMAL(10,2) DEFAULT 0.00")
        except mysql.connector.Error as err:
            if err.errno == 1060:
                pass
            else:
                print("Error altering storemanager:", err)
        
        # Initialize storemanager wallet with historic sum of order totals
        cursor.execute("""
            UPDATE storemanager m 
            JOIN (SELECT StoreID, SUM(TotalBillAmount) as total FROM orders WHERE OrderStatus != 'Cancelled' GROUP BY StoreID) o 
            ON m.StoreID = o.StoreID 
            SET m.WalletBalance = IFNULL(o.total, 0)
        """)

        tables = [
            """
            CREATE TABLE IF NOT EXISTS custombaskets (
                BasketID INT AUTO_INCREMENT PRIMARY KEY,
                CustomerID INT,
                BasketName VARCHAR(100),
                ProductIDs JSON,
                FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS wallettransfers (
                TransferID INT AUTO_INCREMENT PRIMARY KEY,
                CustomerID INT,
                ManagerID INT,
                Amount DECIMAL(10,2),
                TransferDate DATETIME,
                OrderID INT,
                FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
                FOREIGN KEY (ManagerID) REFERENCES storemanager(ManagerID),
                FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
            )
            """
        ]

        for stmt in tables:
            cursor.execute(stmt)

        db.commit()
        print("Wallet fields and tables added successfully.")

    except Exception as e:
        print("Database Update Error:", e)
    finally:
        if 'db' in locals() and db.is_connected():
            cursor.close()
            db.close()

if __name__ == "__main__":
    wallet_update()
