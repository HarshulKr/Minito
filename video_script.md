# Minito DBMS Project: 12-Minute Video Presentation Script

**Overview:** 
This script is designed for a 12-minute video (roughly 2 minutes per task) at a normal speaking pace of 130-150 words per minute.

---

## ⏱️ [0:00 - 2:00] Task 1: Project Scope & Business Requirements

**📺 What should be on the screen:**
- Title Slide: "Minito: Multi-Store Quick-Commerce Platform".
- Bullet points highlighting: 10-Minute Delivery, High Concurrency, Multi-Store Architecture, and Role-Based Access Control.
- A brief demo of the frontend, showing the login screen and browsing products.

**🗣️ Speech:**
"Hello everyone, welcome to the presentation of our DBMS project, 'Minito'. Minito is a high-concurrency quick-commerce fulfillment platform, inspired by localized delivery apps like Blinkit or Zepto. Our primary business requirement was to architect a system capable of handling thousands of parallel transactions while ensuring rapid, 10-minute automated delivery delegation. 

The scope of our platform spans four key roles: the Customer, who browses and purchases groceries; the Store Manager, overseeing localized dark store inventory; the Delivery Partner, handling the logistics; and the global Administrator. 

Our application goes beyond a basic e-commerce store. It incorporates a comprehensive, multi-store orchestration system. We designed Minito to intelligently split a single user's cart across multiple regional dark stores based on real-time global inventory availability. Furthermore, the platform requires a highly accurate state management system for delivery personnel to avoid double-assignment, and includes features like dynamic flash sales, product combos, and an internal digital wallet ecosystem which dictates all financial movement across the application. Let's look into how we modeled this."

---

## ⏱️ [2:00 - 4:00] Task 2: Conceptual & Relational Model

**📺 What should be on the screen:**
- Visual 1: The Entity-Relationship (ER) Diagram highlighting major entities (`Customer`, `DarkStore`, `Products`, `Orders`, `DeliveryPartner`).
- Visual 2: Transition slide showing the conversion from ER to the Relational Schema (Tables with arrows indicating Foreign Key constraints).

**🗣️ Speech:**
"Moving on to our conceptual design, we started with a robust Entity-Relationship diagram. The heart of our model consists of several strong entities. We have `Customers`, `Products`, `DarkStores`, and `DeliveryPartners`. 

When translating this into our relational model, we accounted for various relationship cardinalities. For example, a single customer can place many orders, creating a one-to-many relationship. A single order, however, contains multiple products, and a single product can be in multiple orders, resolving into a many-to-many relationship using the `OrderItem` bridging table. 

Similarly, our inventory isn't global; it's localized. So we designed a `StoreInventory` associative entity holding composite primary keys mapping `StoreID` to `ProductID` alongside stock quantities. 

A unique challenge in our conceptual model was the multi-store checkout. Because an order can be fulfilled by multiple dark stores, our relational model dictates that an `Order` tuple belongs to exactly one `CustomerID`, one `StoreID`, and one `DeliveryPartnerID`. If a customer buys items from two different locations, the system generates two distinct relational order rows, enforcing strict data normalization and maintaining logical isolation."

---

## ⏱️ [4:00 - 6:00] Task 3: Schema, Constraints & Data Insertion

**📺 What should be on the screen:**
- A shot of the MySQL Workbench showing `SHOW TABLES;` and `DESCRIBE orders;`.
- Highlighting Primary Keys (PK), Foreign Keys (FK), and Integrity Constraints natively built.
- A quick scroll through the `Dump20260415.sql` file showing thousands of rows of `INSERT` statements.

**🗣️ Speech:**
"For Task 3, we materialized our relational model into a MySQL database schema with rigorous integrity constraints. Every table relies on auto-incrementing surrogate primary keys, such as `OrderID` or `PartnerID`, ensuring flawless indexing and join performance.

To enforce relational integrity, we heavily utilized foreign key constraints. For example, if a dark store is removed, we've structured our schema to handle the cascading impact on its localized inventory and assigned employees. We also added strict domain constraints, utilizing `DECIMAL(10,2)` for financial calculations in our wallets, and boolean fields like `is_available` in the delivery partner table to toggle logistics states on and off. 

To prove our database behaves beautifully under scale, we generated and populated substantial simulated data. We inserted hundreds of products spanning multiple categories, thousands of inventory rows mapped across ten distinct regional dark stores, and registered over two hundred customers with simulated initial wallet balances. We populated dummy transactions natively into MySQL to ensure that immediately upon launching our Python backend, the app reflects real-world saturation."

---

## ⏱️ [6:00 - 8:00] Task 4: Complex SQL Queries

**📺 What should be on the screen:**
- Split screen: A code editor showing the specific Python/SQL queries embedded in the backend vs. the resulting frontend UI updating in real-time.
- Highlight at least 3 distinct, complex SQL query structures (Joins, Aggregations, Subqueries).

**🗣️ Speech:**
"In Task 4, we implemented well over 15 dynamic SQL queries of varying complexities to breathe life into the application. While simple `SELECT` and `INSERT` statements populate our login screens and catalogue, the real power lies in our analytical and joined queries.

For example, when a user views their order history, we execute an N-way `JOIN` combining the `Orders`, `DarkStore`, `OrderItem`, and `Products` tables. This multi-join query efficiently reconstructs the entire user context in one network trip, mapping product names and localized store locations directly to the customer's feed. 

Another highly complex query we wrote handles our proprietary inventory delegation. When a user requests 5 units of 'Amul Milk', our query uses sophisticated filtering: `SELECT storeid FROM storeinventory WHERE productid = X AND Quantity >= 5 LIMIT 1`. This immediately locates the optimal fulfillment center. We also utilized aggregate functions—summing groupings to calculate localized sub-totals—allowing us to bill exact split fractional amounts and appropriately distribute commission queries to logistics and store manager dashboards. All relational algebraic operations logic stems purely from our optimized SQL queries."

---

## ⏱️ [8:00 - 10:00] Task 5: Embedded SQL & Triggers

**📺 What should be on the screen:**
- Code snippets from `backend/routes/order.py` demonstrating Python's MySQL connector integration, highlighting parameterized query bindings (`%s` syntax).
- Code snippets of two essential SQL `CREATE TRIGGER` statements natively installed in the database to automate business rules.

**🗣️ Speech:**
"For Task 5, we connected our frontend UI to the database via a Python Flask API, acting as an embedded SQL layer. We utilized `PyMySQL` to open stateful connections, strictly using explicit cursor execution and parameterized bindings to ensure complete immunity against SQL Injection attacks. Every button click on the frontend translates to parameterized native SQL execution in our Flask routes.

Furthermore, we shifted specific logical responsibilities directly into the database engine using SQL Triggers. We defined two critical triggers. 
The first is a data-validation trigger: `BEFORE UPDATE ON customer`. It checks if a transaction is about to push a customer's `WalletBalance` below zero. If it does, the trigger leverages the `SIGNAL SQLSTATE` command to elegantly abort the transaction, guaranteeing that impossible financial states never hit the ledger. 

Our second trigger sits on the `Orders` table: `AFTER INSERT ON orders`. Whenever a new order tuple is finalized, this trigger automatically reaches over to the `DeliveryPartner` table and updates the assigned rider's `is_available` boolean to FALSE, automating our logistics pipeline purely at the database level without requiring slower backend compute."

---

## ⏱️ [10:00 - 12:00] Task 6: Database Transactions & Concurrency

**📺 What should be on the screen:**
- A diagram showing two users attempting to checkout the same final product at the exact same time.
- Code blocks showing: `db.cursor.execute("BEGIN")` -> `SELECT ... FOR UPDATE` -> `COMMIT` / `ROLLBACK`.

**🗣️ Speech:**
"Finally, Task 6 addresses database transactions under hostile, concurrent environments. Minito serves multiple users simultaneously; therefore, race conditions are inevitable. 

We wrapped all multi-step pipelines—like the checkout process and order cancellation—in strict atomic blocks using explicit `BEGIN`, `COMMIT`, and `ROLLBACK` commands. If an order fails halfway through generating items because a server crashes, the entire transaction rolls back, leaving no orphaned data.

To solve conflicting transactions, like two users racing to buy the last unit of stock in a dark store, we utilized Guarded Updates. The database attempts to safely deduct stock with checking the limits simultaneously (`Quantity = Quantity - X WHERE Quantity >= X`). If the rowcount comes back as zero, it means parallel depletion occurred, triggering an immediate safety rollback. 
Furthermore, for our Order Cancellation pipeline, we implemented Pessimistic Locking. By executing a `SELECT ... FOR UPDATE`, we place an exclusive row-level lock on the order, preventing any asynchronous delivery routines from picking up an order while a customer is simultaneously trying to cancel it. This guarantees complete ACID compliance."
