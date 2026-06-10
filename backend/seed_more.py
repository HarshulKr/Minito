import mysql.connector

def seed_more():
    try:
        db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="hansika",
            database="minito_db"
        )
        cursor = db.cursor()

        # Add 5 employees to each of the 10 stores
        employee_data = []
        for store_id in range(1, 11):
            for i in range(1, 6):
                role = "Picker" if i % 2 == 0 else "Packer"
                employee_data.append((f"Store {store_id} Emp {i}", role, store_id))
        
        cursor.executemany(
            "INSERT INTO employee (Name, Role, StoreID) VALUES (%s, %s, %s)", 
            employee_data
        )
        db.commit()
        print(f"Added {len(employee_data)} employees.")

        # Add 20 more combos
        combos = [
            ("Morning Breakfast", 250.00, 1, ['%Amul Milk 1L%', '%Amul Butter 500g%', '%Kellogg Cornflakes%']),
            ("Healthy Snacking", 900.00, 1, ['%Almonds 500g%', '%Cashews 500g%', '%Raisins 500g%']),
            ("First Aid Kit", 200.00, 2, ['%Band Aid Strips%', '%Dettol Antiseptic Liquid%', '%Cotton Roll%']),
            ("Movie Night", 150.00, 1, ['%Lays Classic Chips%', '%Kurkure Masala%', '%Coca Cola 1L%', '%Dairy Milk%']),
            ("Hygiene Essentials", 250.00, 1, ['%Dove Soap%', '%Clinic Plus Shampoo%', '%Colgate Toothpaste%']),
            ("Fresh Veggies", 150.00, 1, ['%Potato 1kg%', '%Onion 1kg%', '%Tomato 1kg%', '%Carrot 1kg%']),
            ("Essential Groceries", 800.00, 1, ['%Aashirvaad Atta 5kg%', '%Fortune Sunflower Oil 1L%', '%Tata Salt 1kg%', '%India Gate Basmati Rice 5kg%']),
            ("Cold Relief", 200.00, 2, ['%Vicks Vaporub%', '%Crocin 500mg%', '%Honitus%']),
            ("Fever Care", 1600.00, 2, ['%Dolo 650%', '%Electral%', '%Digital Thermometer%']),
            ("Tea Time", 120.00, 1, ['%Parle-G%', '%Britannia Marie Gold%', '%Britannia Good Day%', '%Amul Milk 500ml%']),
            ("Energy Boost", 350.00, 1, ['%Red Bull%', '%Snickers%', '%Bournvita%']),
            ("Hair Care", 2500.00, 1, ['%Head & Shoulders%', '%Syska Hair Dryer%', '%Philips Hair Straightener%']),
            ("PC Peripherals", 1800.00, 3, ['%Wireless Mouse%', '%Keyboard USB%', '%Pendrive 32GB%']),
            ("Gamer Pack", 2000.00, 3, ['%Gaming Mouse%', '%Laptop Cooling Pad%', '%Red Bull%']),
            ("Smart Home Starter", 6000.00, 3, ['%Smart Bulb%', '%Smart Plug%', '%Echo Dot%']),
            ("Fast Charging", 1500.00, 3, ['%Mi Power Bank 10000mAh%', '%Mi Fast Charger%', '%USB Type-C%']),
            ("Audio Enthusiast", 7000.00, 3, ['%Boat Airdopes%', '%JBL Flip Speaker%']),
            ("Winter Care", 400.00, 1, ['%Nivea Cream%', '%Boroline%', '%Horlicks Classic%']),
            ("Cleaning Supplies", 450.00, 1, ['%Surf Excel 1kg%', '%Vim Dishwash Bar%', '%Lizol Floor Cleaner%', '%Harpic Toilet Cleaner%']),
            ("Choco Delight", 850.00, 1, ['%Ferrero Rocher%', '%Toblerone%', '%Galaxy Chocolate%'])
        ]

        inserted_combos = 0
        for combo_name, price, category, keywords in combos:
            cursor.execute("INSERT INTO combos (ComboName, BasePrice, CategoryID) VALUES (%s, %s, %s)", (combo_name, price, category))
            combo_id = cursor.lastrowid
            
            for kw in keywords:
                cursor.execute("SELECT ProductID FROM products WHERE ProductName LIKE %s LIMIT 1", (kw,))
                res = cursor.fetchone()
                if res:
                    pid = res[0]
                    try:
                        cursor.execute("INSERT INTO comboitems (ComboID, ProductID) VALUES (%s, %s)", (combo_id, pid))
                    except mysql.connector.errors.IntegrityError:
                        pass
            inserted_combos += 1
            
        db.commit()
        print(f"Added {inserted_combos} combos and their items.")

    except Exception as e:
        print("Error:", e)
    finally:
        if 'db' in locals() and db.is_connected():
            cursor.close()
            db.close()

if __name__ == "__main__":
    seed_more()
