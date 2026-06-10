import React, { useEffect, useState } from "react";
import axios from "axios";
import { Card, Button, message, Steps, Typography, Statistic, Row, Col, notification, Table, Tag } from "antd";

const { Title, Text } = Typography;

function DeliveryApp({ user, setPage }) {
  const [orders, setOrders] = useState([]);
  const [availableOrders, setAvailableOrders] = useState([]);
  const [earningsInfo, setEarningsInfo] = useState({ earnings: 0, completed: 0, total_wallet: 0, history: [] });

  const isAvailable = orders.length === 0;

  useEffect(() => {
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchData = async () => {
    try {
      const [resOrders, resEarning] = await Promise.all([
        axios.get(`http://${window.location.hostname}:5000/delivery/orders/${user.PartnerID}`),
        axios.get(`http://${window.location.hostname}:5000/delivery/earnings/${user.PartnerID}`)
      ]);
      setOrders(resOrders.data);
      setEarningsInfo(resEarning.data);

      if (resOrders.data.length === 0) {
          const resAvail = await axios.get(`http://${window.location.hostname}:5000/delivery/available-orders/${user.storeid}`);
          setAvailableOrders(resAvail.data);
      } else {
          setAvailableOrders([]);
      }
    } catch (err) {
      console.error(err);
      message.error("Failed to fetch delivery data.");
    }
  };

  const updateStatus = async (orderId, newStatus) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/delivery/orders/update`, {
        order_id: orderId,
        status: newStatus
      });
      message.success(`Status updated to ${newStatus}`);
      fetchData(); 
    } catch (err) {
      console.error(err);
      message.error("Failed to update status");
    }
  };

  const handleAccept = async (orderId) => {
      try {
          await axios.post(`http://${window.location.hostname}:5000/delivery/accept-order`, {
              partner_id: user.PartnerID,
              order_id: orderId
          });
          message.success("Order Successfully Claimed!");
          fetchData(); 
      } catch (err) {
          if (err.response?.status === 409) {
              notification.error({
                  message: "Claim Failed",
                  description: "Order already claimed by another partner!"
              });
              fetchData();
          } else {
              message.error("Error accepting order.");
          }
      }
  };

  const workflow = ["Placed", "Packed", "Picked", "Out for Delivery", "Delivered"];

  const historyColumns = [
      { title: 'Date', dataIndex: 'OrderDateTime', key: 'OrderDateTime', render: d => new Date(d).toLocaleString() },
      { title: 'Order ID', dataIndex: 'OrderID', key: 'OrderID' },
      { title: 'Commission Earned', dataIndex: 'CommissionEarned', key: 'CommissionEarned', render: val => <span style={{color:'green', fontWeight:'bold'}}>+₹{val}</span> }
  ];

  return (
    <div style={{ padding: "20px", maxWidth: 900, margin: "auto" }}>
      <div className="blinkit-header" style={{ marginBottom: 20, display: 'flex', justifyContent: 'space-between' }}>
        <span>Delivery Interface - {user.Name}</span>
        <span>Store: {user.storeid}</span>
      </div>

      <Row gutter={16} style={{ marginBottom: 20 }}>
        <Col span={8}>
          <Card>
            <Statistic title="Today's Earnings" value={earningsInfo.earnings} prefix="₹" valueStyle={{ color: '#cf1322' }}/>
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="Total Wallet Balance" value={earningsInfo.total_wallet} prefix="₹" valueStyle={{ color: '#3f8600' }}/>
          </Card>
        </Col>
        <Col span={8}>
          <Card>
            <Statistic title="Orders Delivered Today" value={earningsInfo.completed} />
          </Card>
        </Col>
      </Row>

      <Row gutter={16}>
        <Col span={14}>
            <Title level={4}>Assigned Active Orders</Title>
            {orders.length === 0 ? (
                <Card style={{ textAlign: 'center', backgroundColor: '#f5f5f5' }}>
                    <Text type="secondary">No active orders assigned. Available for dispatch.</Text>
                </Card>
            ) : (
                orders.map(order => {
                   let curIdx = workflow.indexOf(order.OrderStatus);
                   if (curIdx === -1) curIdx = 0; 

                   return (
                     <Card key={order.OrderID} style={{ marginBottom: 20 }} title={`Active Mission: Order #${order.OrderID}`}>
                        <Steps 
                           size="small" 
                           current={curIdx} 
                           items={workflow.map(t => ({ title: t }))} 
                           style={{ marginBottom: 20 }}
                        />

                        <div style={{ marginBottom: 15, padding: 10, background: '#fafafa', borderRadius: 8 }}>
                           <Text strong>Customer: </Text> <Text>{order.CustomerName}</Text><br/>
                           <Text strong>Address: </Text> <Text>{order.Address}</Text><br/>
                           <Text strong>Phone: </Text> <Text>{order.PhoneNumber}</Text>
                        </div>

                        <div style={{ display: 'flex', gap: 10 }}>
                           {order.OrderStatus === "Placed" && (
                               <Button disabled>Waiting for Store Manager to Pack...</Button>
                           )}
                           {order.OrderStatus === "Packed" && (
                               <Button type="primary" onClick={() => updateStatus(order.OrderID, "Picked")}>Mark Picked</Button>
                           )}
                           {order.OrderStatus === "Picked" && (
                               <Button type="primary" onClick={() => updateStatus(order.OrderID, "Out for Delivery")}>Mark Out for Delivery</Button>
                           )}
                           {order.OrderStatus === "Out for Delivery" && (
                               <Button type="primary" style={{backgroundColor: '#52c41a', borderColor: '#52c41a'}} onClick={() => updateStatus(order.OrderID, "Delivered")}>Confirm Delivery</Button>
                           )}
                        </div>
                     </Card>
                   );
                })
            )}
        </Col>
        <Col span={10}>
            <Title level={4}>Ready For Pickup (Floating)</Title>
            {!isAvailable ? (
                <Card style={{ textAlign: 'center', borderColor: '#ffccc7' }}>
                   <Text type="danger">Complete your current assignment to unlock more floating orders.</Text>
                </Card>
            ) : availableOrders.length === 0 ? (
                <Text type="secondary">No local floating orders wait list right now.</Text>
            ) : (
                availableOrders.map(o => (
                   <Card key={o.OrderID} style={{ marginBottom: 15, borderColor: '#1890ff', borderLeft: '5px solid #1890ff' }} size="small">
                      <div style={{ marginBottom: 10 }}>
                         <strong>Order #{o.OrderID}</strong><br/>
                         <span><Text type="secondary">Destination: </Text> {o.Address}</span><br/>
                         <span><Text type="secondary">Payout: </Text> <Tag color="green">₹50 Flat</Tag></span>
                      </div>
                      <Button type="primary" block onClick={() => handleAccept(o.OrderID)}>Accept Order</Button>
                   </Card>
                ))
            )}
        </Col>
      </Row>
      
      <div style={{ marginTop: 40 }}>
         <Title level={4}>Earnings History (Last 10 Actions)</Title>
         <Table 
            dataSource={earningsInfo.history} 
            columns={historyColumns} 
            rowKey="OrderID" 
            size="small" 
            pagination={false} 
         />
      </div>

      <Button onClick={() => setPage(null)} style={{marginTop: 40, width: '100%'}} danger>Logout</Button>
    </div>
  );
}

export default DeliveryApp;
