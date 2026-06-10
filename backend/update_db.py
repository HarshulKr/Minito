import mysql.connector

def update_db():
    try:
        db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="hansika",
            database="minito_db"
        )
        cursor = db.cursor()

        # Create Tables
        tables = [
            """
            CREATE TABLE IF NOT EXISTS employee (
                EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
                Name VARCHAR(100),
                Role VARCHAR(50),
                StoreID INT,
                FOREIGN KEY (StoreID) REFERENCES darkstore(StoreID)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS combos (
                ComboID INT AUTO_INCREMENT PRIMARY KEY,
                ComboName VARCHAR(100),
                BasePrice DECIMAL(10,2),
                CategoryID INT,
                FOREIGN KEY (CategoryID) REFERENCES category(CategoryID)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS comboitems (
                ComboID INT,
                ProductID INT,
                PRIMARY KEY (ComboID, ProductID),
                FOREIGN KEY (ComboID) REFERENCES combos(ComboID),
                FOREIGN KEY (ProductID) REFERENCES products(ProductID)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS userbaskets (
                BasketID INT AUTO_INCREMENT PRIMARY KEY,
                CustomerID INT,
                BasketName VARCHAR(100),
                FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID)
            )
            """,
            """
            CREATE TABLE IF NOT EXISTS userbasketitems (
                BasketID INT,
                ProductID INT,
                PRIMARY KEY (BasketID, ProductID),
                FOREIGN KEY (BasketID) REFERENCES userbaskets(BasketID),
                FOREIGN KEY (ProductID) REFERENCES products(ProductID)
            )
            """
        ]

        for stmt in tables:
            cursor.execute(stmt)

        db.commit()

        print("Tables created successfully.")

        # Seed Employees
        cursor.execute("SELECT COUNT(*) FROM employee")
        if cursor.fetchone()[0] == 0:
            cursor.execute("INSERT INTO employee (Name, Role, StoreID) VALUES ('John Doe', 'Picker', 1), ('Jane Smith', 'Packer', 1), ('Alice', 'Packer', 2)")
            db.commit()

        # Seed combos
        cursor.execute("SELECT COUNT(*) FROM combos")
        if cursor.fetchone()[0] == 0:
            combos = [
                ("Maggi Party Combo", 150.00, 1),
                ("Italian Dinner", 400.00, 1),
                ("Monsoon Care", 250.00, 2),
                ("Grooming Kit", 500.00, 1),
                ("Work From Home", 1200.00, 3)
            ]
            for combo in combos:
                cursor.execute("INSERT INTO combos (ComboName, BasePrice, CategoryID) VALUES (%s, %s, %s)", combo)
            db.commit()

            cursor.execute("SELECT ComboID, ComboName FROM combos")
            combo_map = {name: cid for cid, name in cursor.fetchall()}

            # Populate comboitems
            combo_items = [
                (combo_map["Maggi Party Combo"], ['%Maggi Noodle%', '%Cheese Slice%', '%Hot & Sweet%']),
                (combo_map["Italian Dinner"], ['%Pasta Penne%', '%Olive Oil%', '%Salt%']),
                (combo_map["Monsoon Care"], ['%Paracetamol%', '%Cough Syrup%', '%Vitamin C%', '%Zincovit%']),
                (combo_map["Grooming Kit"], ['%Trimmer%', '%Soap%', '%Shampoo%']),
                (combo_map["Work From Home"], ['%Mouse%', '%Keyboard%', '%Cable%', '%Earphone%'])
            ]

            for cid, keywords in combo_items:
                for kw in keywords:
                    cursor.execute("SELECT ProductID FROM products WHERE ProductName LIKE %s LIMIT 1", (kw,))
                    res = cursor.fetchone()
                    if res:
                        pid = res[0]
                        # avoid duplicate entries
                        try:
                            cursor.execute("INSERT INTO comboitems (ComboID, ProductID) VALUES (%s, %s)", (cid, pid))
                        except mysql.connector.errors.IntegrityError:
                            pass

            db.commit()
            print("Seed data inserted successfully.")

    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    update_db()
