import { useState } from "react";
import Login from "./Login";
import Products from "./Products";
import Cart from "./Cart";
import OrderHistory from "./OrderHistory";
import AdminDashboard from "./AdminDashboard";
import ManagerInventory from "./ManagerInventory";
import DeliveryApp from "./DeliveryApp";

function App() {
  const [user, setUser] = useState(null);
  const [page, setPage] = useState("products");

  if (!user) return <Login setUser={setUser} />;

  // Multi-role dispatch
  if (user.Role === "Admin") return <AdminDashboard user={user} setPage={setUser} />;
  if (user.Role === "Store Manager") return <ManagerInventory user={user} setPage={setUser} />;
  if (user.Role === "Delivery Partner") return <DeliveryApp user={user} setPage={setUser} />;

  // Customer logic
  if (page === "products") return <Products user={user} setPage={setPage} setUser={setUser} />;
  if (page === "cart") return <Cart user={user} setPage={setPage} />;
  if (page === "orders") return <OrderHistory user={user} setPage={setPage} />;
}

export default App;