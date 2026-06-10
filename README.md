

# Minito: Multi-Store Quick-Commerce Platform

Minito is a high-concurrency quick-commerce fulfillment platform designed for localized logistics and rapid delivery. The architecture supports a multi-tenant model where customers can transact with multiple regional branches (Dark Stores) within a single checkout session, supported by robust inventory delegation and automated delivery assignment logic.

## Technical Architecture and Features

### Multi-Store Order Orchestration
The backend implements an intelligent order-splitting algorithm. During the checkout phase, the system evaluates global inventory across localized branches and groups cart items by StoreID.
* **Decoupled Fulfillment**: Generates distinct Order entities for regional Managers, ensuring data isolation between branches.
* **Partial Fulfillment Logic**: Items that cannot be fulfilled remain in the user's cart, preventing transaction failure while maintaining cart persistence.

### Relational Integrity and Security
Critical systemic paths are hardened against data mutation and network instability through physical database constraints:
* **ACID Compliance**: All checkout pipelines are wrapped in strict BEGIN, COMMIT, and ROLLBACK blocks to ensure atomicity.
* **Concurrency Control**: Implements pessimistic locking and guarded updates to manage high-frequency parallel requests.

### Role-Based Access Control (RBAC)
The platform is partitioned into four distinct hierarchical control planes with scoped authorization:
1. **Administrative Authority**: High-level platform analytics and financial monitoring.
2. **Branch Management**: Granular inventory control, stock-level alerts, and order status management.
3. **Customer Interface**: E-commerce shopping experience with integrated digital wallet management.
4. **Logistics Dashboard**: Asynchronous order-claiming interface for delivery partners with automated availability state management.

### Inventory Lifecycle Management
Includes specialized tools for real-time shelf-life tracking and stock health:
* **Automated Disposal/Restock**: Synchronous stock updates to clear expired inventory.
* **Dynamic Pricing**: Functionality for rapid Flash Sale deployment and Product Combo grouping.

## Tech Stack
* **Backend**: Python (Flask) utilizing a modular Blueprint architecture.
* **Database**: MySQL with complex relational mapping and referential integrity.
* **Frontend**: React (Vite) and Ant Design for a responsive, state-driven UI.
* **State Management**: Persistent local storage and React Hook-based state propagation.

## Database Schema Overview
* **customer**: Manages user profiles and financial ledgers.
* **darkstore**: Physical locations mapped to localized storeinventory.
* **orders**: Transactional records joined by Store, Customer, and Delivery Partner entities.
* **deliverypartner**: Logistics profiles regulated by is_available states.

## Installation and Deployment

### 1. Database Initialization
Install MySQL and execute the schema initialization scripts to establish the relational tables and constraints.

### 2. Backend Configuration
Navigate to the /backend directory and execute:
`python app.py`
The server initializes on port 5000.

### 3. Frontend Deployment
Navigate to the /frontend directory and execute:
`npm run dev -- --host`
The React application serves on port 5173 (or 3000) and is exposed to the local network via the --host flag.

## Concurrency Analysis: Integrity Audit (Task 6)

Minito implements specific mitigation strategies for common distributed system race conditions:

### Inventory Depletion Race (Last-Item Paradox)
To prevent overselling when two users attempt to purchase the same inventory unit simultaneously, Minito utilizes **Guarded Updates**. If a parallel transaction has already depleted the stock, the database returns a rowcount of zero, triggering an immediate ROLLBACK of the entire customer transaction.

### Logistics Assignment Collision (Double-Claim)
To prevent multiple delivery partners from claiming the same order, the system utilizes **Pessimistic Locking**:
1. **Row Locking**: Using SELECT ... FOR UPDATE locks the specific order row.
2. **State Verification**: The second transaction is forced to wait until the first is completed, at which point it encounters a non-null DeliveryPartnerID and returns a 409 Conflict error, ensuring one order per rider.
