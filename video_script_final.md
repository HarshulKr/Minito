# Minito DBMS Project: 12-Minute Video Presentation Script

**Team Members:**

- Member 1: [Name], Roll Number: [Roll1], Project Number: DBMS-001
- Member 2: [Name], Roll Number: [Roll2], Project Number: DBMS-001
- Member 3: [Name], Roll Number: [Roll3], Project Number: DBMS-001

**Overview:**
This script is designed for a 12-minute video, with each member speaking for at least 2 minutes. Tasks are divided among speakers to balance time. Speaking pace: 130-150 words per minute.

---

## ⏱️ [0:00 - 0:30] Introduction (All Members)

**📺 What should be on the screen:**

- Title Slide: "Minito: Multi-Store Quick-Commerce Platform - DBMS Project Presentation"
- Team member names, roll numbers, and project number displayed.

**🗣️ Speech (All together):**
"Hello everyone, we are [Member 1 Name], [Member 2 Name], and [Member 3 Name] from [Class/Section]. Our roll numbers are [Roll1], [Roll2], and [Roll3]. This is Project Number DBMS-001. Today, we will present our DBMS project, Minito, a multi-role quick-commerce platform."

---

## ⏱️ [0:30 - 1:30] Task 1: Project Scope (Business Requirements) - Speaker 1 (~1 minute)

**📺 What should be on the screen:**

- Slides showing problem statement, target users, key features, assumptions.
- Demo of frontend login and product browsing.

**🗣️ Speech (Speaker 1):**
"Minito addresses the problem of inefficient quick-commerce logistics in localized delivery systems, similar to Blinkit or Zepto. Our target users are customers needing fast grocery delivery, store managers handling inventory, delivery partners for logistics, and admins for oversight.

Key features include multi-store order orchestration, intelligent cart splitting, real-time inventory management, flash sales, and digital wallet integration. We assumed high concurrency with ACID compliance and role-based access control.

A database is essential for managing complex relationships, ensuring data integrity, and handling concurrent transactions in this logistics-enabled e-commerce platform."

---

## ⏱️ [1:30 - 3:30] Task 2: Conceptual Model (ER Diagram → Relational Model) - Speaker 1 (~2 minutes)

**📺 What should be on the screen:**

- ER Diagram showing entities: Customer, DarkStore, Product, Order, DeliveryPartner, etc.
- Transition to Relational Schema with tables and relationships.

**🗣️ Speech (Speaker 1):**
"Our ER diagram captures business requirements with entities like Customer, Product, DarkStore, Order, and DeliveryPartner. Relationships include one-to-many (Customer to Orders), many-to-many (Order to Products via OrderItem), and associative entities like StoreInventory.

Converting to relational model, we used surrogate keys for efficiency. For multi-store orchestration, Orders are split by StoreID. Constraints include foreign keys for referential integrity, unique constraints on emails, and check constraints for positive quantities.

This model ensures data normalization, supports complex queries, and maintains consistency in our quick-commerce system."

---

## ⏱️ [3:30 - 5:30] Task 3: Schema Design & Data - Speaker 2 (~2 minutes)

**📺 What should be on the screen:**

- MySQL Workbench showing tables: DESCRIBE customer, orders, etc.
- Sample data inserts from Dump20260415.sql.
- Indexes and constraints highlighted.

**🗣️ Speech (Speaker 2):**
"Our schema includes tables like customer (profiles, wallet), darkstore (locations), products, orders, deliverypartner, and associative tables like orderitem and storeinventory.

Keys: Primary keys are auto-incrementing (e.g., CustomerID). Foreign keys link entities (Order.CustomerID → Customer.ID). Constraints: NOT NULL for essentials, UNIQUE on emails, CHECK for positive values.

We populated with simulated data: 1000+ customers, products across stores, realistic orders. Data is consistent with referential integrity and meaningful for testing features like inventory depletion and delivery assignment."

---

## ⏱️ [5:30 - 8:30] Task 4: SQL Queries - Speaker 2 (~3 minutes)

**📺 What should be on the screen:**

- Code snippets of SQL queries in MySQL Workbench.
- Query results displayed.
- Examples: SELECT, JOIN, subqueries, triggers.

**🗣️ Speech (Speaker 2):**
"We implemented diverse SQL queries: basic SELECT for listings, JOINs for order details, subqueries for analytics, and complex aggregations for reports.

Examples:

- Retrieve customer orders with products: SELECT with JOIN on orderitem.
- Inventory alerts: SELECT products WHERE stock < threshold.
- Revenue analytics: SUM(order_total) GROUP BY store.

These support features like cart management, inventory tracking, and admin dashboards, demonstrating CRUD operations and advanced querying."

---

## ⏱️ [8:30 - 10:30] Task 5: Application + Triggers - Speaker 3 (~2 minutes)

**📺 What should be on the screen:**

- Frontend demo: Login, cart, order placement.
- Backend code snippets showing triggers.
- Trigger examples: Inventory update, wallet deduction.

**🗣️ Speech (Speaker 3):**
"Our Flask backend interacts with MySQL via SQLAlchemy. Frontend React handles UI with API calls.

Triggers:

- Inventory update: AFTER INSERT on orderitem, decrement stock.
- Wallet deduction: BEFORE INSERT on orders, check balance and subtract.
- Delivery assignment: AFTER UPDATE on orders, set partner availability.

These enforce business rules, maintain consistency, and automate processes like stock management and financial transactions."

---

## ⏱️ [10:30 - 12:00] Task 6: DB Transactions Execution - Speaker 3 (~1.5 minutes)

**📺 What should be on the screen:**

- Demo of concurrent transactions: Two users buying last item.
- Code showing BEGIN, COMMIT, ROLLBACK.
- Conflict resolution examples.

**🗣️ Speech (Speaker 3):**
"Transactions ensure ACID properties. For inventory depletion race: Use SELECT FOR UPDATE to lock rows, preventing overselling.

For delivery claim collision: Pessimistic locking ensures one partner per order.

Demo: Simulate two users claiming same order – second gets conflict error. This maintains consistency and handles concurrency in our high-traffic platform."

---

## ⏱️ [12:00] Conclusion (All Members)

**📺 What should be on the screen:**

- Thank you slide with team details.

**🗣️ Speech (All together):**
"Thank you for watching our presentation. We hope you enjoyed learning about Minito. Any questions?"

**Total Time: 12 minutes**
