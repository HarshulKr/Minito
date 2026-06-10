import axios from "axios";
import { useEffect, useState } from "react";
import { Card, Button, Typography, Row, Col, Alert, message, Spin, Tag, InputNumber, Space } from "antd";
import { WalletOutlined, PlusOutlined } from "@ant-design/icons";

const { Title, Text } = Typography;

function Cart({ user, setPage }) {
  const [cart, setCart] = useState([]);
  const [loading, setLoading] = useState(false);
  const [wallet, setWallet] = useState(user.WalletBalance || 0);

  // Add Money State
  const [isAddingMoney, setIsAddingMoney] = useState(false);
  const [topUpAmount, setTopUpAmount] = useState(500);
  const [topUpLoading, setTopUpLoading] = useState(false);

  useEffect(() => {
    fetchCart();
    fetchWallet();
    
    // Background polling every 5 seconds
    const interval = setInterval(async () => {
        try {
            const res = await axios.get(`http://${window.location.hostname}:5000/customer/cart/check-stock/${user.CustomerID}`);
            if (res.data.removed && res.data.removed.length > 0) {
                message.warning(`Heads up! ${res.data.removed.join(", ")} just went out of stock and was automatically removed from your cart.`);
                fetchCart(); // Visually update the cart to match database
            }
        } catch(e) {}
    }, 5000);

    return () => clearInterval(interval);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchCart = async () => {
    try {
      const res = await axios.get(`http://${window.location.hostname}:5000/customer/cart/${user.CustomerID}`);
      setCart(res.data);
    } catch (err) {}
  };

  const fetchWallet = async () => {
    try {
      const res = await axios.get(`http://${window.location.hostname}:5000/customer/wallet/${user.CustomerID}`);
      setWallet(res.data.WalletBalance);
    } catch(err) {}
  };

  const removeItem = async (pid) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/customer/cart/remove`, {
        customer_id: user.CustomerID,
        product_id: pid
      });
      fetchCart();
    } catch (err) {
      alert("Error removing item");
    }
  };

  const placeOrder = async () => {
    setLoading(true);
    try {
      const res = await axios.post(`http://${window.location.hostname}:5000/order/create`, {
        customer_id: user.CustomerID,
        total: total,
        items: cart.map(c => ({ product_id: c.ProductID, qty: c.Quantity }))
      });
      
      if (res.data.unfulfilled && res.data.unfulfilled.length > 0) {
          message.warning(`Order placed! However, ${res.data.unfulfilled.length} item(s) went out of stock and were automatically removed from your cart.`);
      } else {
          message.success("Order Placed Successfully!");
      }
      
      fetchWallet();
      setPage("orders");
    } catch (err) {
      message.error(err.response?.data?.error || "Order failed.");
      if (err.response?.data?.unfulfilled) {
          fetchCart();
      }
    }
    setLoading(false);
  };

  const handleAddMoney = async () => {
      if (!topUpAmount || topUpAmount <= 0) return message.error("Enter a valid amount.");
      setTopUpLoading(true);
      try {
          await axios.post(`http://${window.location.hostname}:5000/customer/wallet/add`, {
              customer_id: user.CustomerID,
              amount: topUpAmount
          });
          message.success(`₹${topUpAmount} added to wallet successfully!`);
          setIsAddingMoney(false);
          setTopUpAmount(500); 
          fetchWallet(); // Reload balance
      } catch(e) {
          message.error("Failed to add funds.");
      }
      setTopUpLoading(false);
  };

  const total = cart.reduce((sum, item) => sum + item.Price * item.Quantity, 0);

  if (cart.length === 0) {
    return (
      <div style={{ padding: "20px", textAlign: "center" }}>
        <h2>Your Cart is Empty</h2>
        <p>Looks like you haven't added anything to your cart yet.</p>
        <Button type="primary" onClick={() => setPage("products")}>Browse Products</Button>
      </div>
    );
  }

  const isLowBalance = parseFloat(wallet) < total;

  return (
    <div style={{ padding: "20px", maxWidth: 800, margin: "auto" }}>
      <div className="blinkit-header" style={{ marginBottom: 20, display: "flex", justifyContent: "space-between", alignItems: 'center' }}>
        <span>Your Cart</span>
        <div style={{ display: 'flex', gap: 15, alignItems: 'center' }}>
            <Tag color={isLowBalance ? "red" : "green"} style={{ fontSize: 16, padding: '4px 10px' }} icon={<WalletOutlined />}>
              Wallet: ₹{parseFloat(wallet).toFixed(2)}
            </Tag>
            <Button onClick={() => setPage("products")}>Back to Products</Button>
        </div>
      </div>

      <Row gutter={16}>
        <Col span={16}>
          {cart.map(c => (
            <Card key={c.ProductID} style={{ marginBottom: 15 }} size="small"
              extra={<Button type="text" danger onClick={() => removeItem(c.ProductID)}>Remove</Button>}
            >
              <Card.Meta 
                title={c.ProductName} 
                description={`₹${c.Price} x ${c.Quantity} = ₹${c.Price * c.Quantity}`} 
              />
            </Card>
          ))}
        </Col>

        <Col span={8}>
          <Card title="Order Summary">
             <Title level={4}>Total: ₹{total.toFixed(2)}</Title>

             {isLowBalance && !isAddingMoney && (
                 <div style={{marginTop: 15, marginBottom: 15}}>
                     <Alert type="error" message="Low Wallet Balance" description="You do not have enough funds to place this order." showIcon style={{marginBottom: 10}} />
                     <Button type="dashed" danger block icon={<PlusOutlined />} onClick={() => setIsAddingMoney(true)}>
                         Add Money to Wallet
                     </Button>
                 </div>
             )}

             {isAddingMoney && (
                 <Card style={{marginBottom: 15, marginTop: 15, backgroundColor: '#f6ffed', borderColor: '#b7eb8f'}}>
                     <Text strong>Top Up Wallet</Text>
                     <Space.Compact style={{ width: '100%', marginTop: 10 }}>
                        <InputNumber 
                           style={{ width: '100%' }} 
                           value={topUpAmount} 
                           onChange={setTopUpAmount} 
                           prefix="₹" 
                           min={1} 
                        />
                        <Button type="primary" onClick={handleAddMoney} loading={topUpLoading}>Add</Button>
                     </Space.Compact>
                     <Button type="link" size="small" style={{marginTop: 5, padding: 0}} onClick={() => setIsAddingMoney(false)}>Cancel</Button>
                 </Card>
             )}

             <Button 
                type="primary" 
                block 
                size="large" 
                disabled={isLowBalance || loading}
                onClick={placeOrder}
             >
                {loading ? <Spin /> : "Place Order"}
             </Button>
          </Card>
        </Col>
      </Row>
    </div>
  );
}

export default Cart;