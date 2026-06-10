import axios from "axios";
import { useEffect, useState } from "react";
import { Card, Steps, Button, Typography, message, Popconfirm, Tag } from "antd";
import { WalletOutlined } from "@ant-design/icons";

const { Title, Text } = Typography;

function OrderHistory({ user, setPage }) {
  const [orders, setOrders] = useState([]);
  const [wallet, setWallet] = useState(user.WalletBalance || 0);

  const loadOrders = () => {
    axios.get(`http://${window.location.hostname}:5000/order/history/${user.CustomerID}`)
      .then(res => setOrders(res.data));
  };

  const fetchWallet = async () => {
    try {
      const res = await axios.get(`http://${window.location.hostname}:5000/customer/wallet/${user.CustomerID}`);
      setWallet(res.data.WalletBalance);
    } catch(err) {}
  };

  useEffect(() => {
    loadOrders();
    fetchWallet();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const cancelOrder = async (orderId) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/order/cancel`, { order_id: orderId });
      message.success("Order Cancelled. Funds refunded to wallet!");
      loadOrders();
      fetchWallet();
    } catch (err) {
      message.error(err.response?.data?.error || "Failed to cancel order");
    }
  };

  const stepsList = ["Placed", "Packed", "Picked", "Out for Delivery", "Delivered"];

  return (
    <div style={{ padding: "20px", maxWidth: 800, margin: "auto" }}>
      <div className="blinkit-header" style={{ marginBottom: 20, display: "flex", justifyContent: "space-between" }}>
        <span>Your Orders</span>
        <div style={{ display: 'flex', gap: 10 }}>
            <Tag color="green" style={{ fontSize: 16, padding: '4px 10px' }} icon={<WalletOutlined />}>
              Wallet: ₹{wallet}
            </Tag>
            <Button onClick={() => setPage("products")}>Back to Products</Button>
        </div>
      </div>

      {orders.map(order => {
        let currentStep = stepsList.indexOf(order.OrderStatus);
        if (order.OrderStatus === "Cancelled") currentStep = -1;
        else if (currentStep === -1) currentStep = 0; // fallback

        return (
          <Card key={order.OrderID} style={{ marginBottom: 20 }} 
            title={`Order #${order.OrderID} - ${order.StoreLocation || 'Local Store'} - ₹${order.TotalBillAmount}`}
            extra={
              order.OrderStatus === 'Placed' && (
                <Popconfirm title="Cancel this order? Money will be refunded to Digital Wallet." onConfirm={() => cancelOrder(order.OrderID)}>
                  <Button danger size="small">Cancel Order</Button>
                </Popconfirm>
              )
            }
          >
            {order.OrderStatus === "Cancelled" ? (
              <Title level={4} type="danger">This order was cancelled. (Refunded)</Title>
            ) : (
              <Steps size="small" current={currentStep} items={[
                  { title: 'Placed' },
                  { title: 'Packed' },
                  { title: 'Picked' },
                  { title: 'Out for Delivery' },
                  { title: 'Delivered' },
                ]}
                style={{ marginBottom: 20 }}
              />
            )}
            
            <Title level={5}>Items:</Title>
            <ul style={{ paddingLeft: 20 }}>
              {order.items.map((item, i) => (
                <li key={i}>
                  <Text>{item.ProductName} × {item.QuantityOrdered}</Text>
                </li>
              ))}
            </ul>
          </Card>
        );
      })}
    </div>
  );
}

export default OrderHistory;