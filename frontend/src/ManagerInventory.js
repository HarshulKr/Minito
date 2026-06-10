import React, { useEffect, useState } from "react";
import axios from "axios";
import { Table, Card, Button, message, Tag, Tabs, Modal, Form, Input, Select, InputNumber, Space } from "antd";

function ManagerInventory({ user, setPage }) {
  const [alerts, setAlerts] = useState([]);
  const [orders, setOrders] = useState([]);
  const [employees, setEmployees] = useState([]);
  const [partners, setPartners] = useState([]);
  
  const [fullInventory, setFullInventory] = useState([]);
  const [categoryFilter, setCategoryFilter] = useState("All");

  const [isEmpModalVisible, setIsEmpModalVisible] = useState(false);
  const [empForm] = Form.useForm();
  
  const [isRestockModalVisible, setIsRestockModalVisible] = useState(false);
  const [currentRestockProduct, setCurrentRestockProduct] = useState(null);
  const [restockForm] = Form.useForm();

  const [isDisposeModalVisible, setIsDisposeModalVisible] = useState(false);
  const [disposeForm] = Form.useForm();
  const [currentDisposeProduct, setCurrentDisposeProduct] = useState(null);

  const [isComboModalVisible, setIsComboModalVisible] = useState(false);
  const [comboForm] = Form.useForm();
  const [currentComboProduct, setCurrentComboProduct] = useState(null);

  // PACK / PARTNER STATE
  const [isPackModalVisible, setIsPackModalVisible] = useState(false);
  const [packForm] = Form.useForm();
  const [currentPackOrder, setCurrentPackOrder] = useState(null);

  useEffect(() => {
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchData = async () => {
    try {
      const [resAlerts, resOrders, resEmps, resFullInv, resPartners] = await Promise.all([
        axios.get(`http://${window.location.hostname}:5000/manager/inventory/${user.StoreID}`),
        axios.get(`http://${window.location.hostname}:5000/manager/orders/${user.StoreID}`),
        axios.get(`http://${window.location.hostname}:5000/manager/employees/${user.StoreID}`),
        axios.get(`http://${window.location.hostname}:5000/manager/inventory/full/${user.StoreID}`),
        axios.get(`http://${window.location.hostname}:5000/manager/partners/${user.StoreID}`)
      ]);
      setAlerts(resAlerts.data);
      setOrders(resOrders.data);
      setEmployees(resEmps.data);
      setFullInventory(resFullInv.data);
      setPartners(resPartners.data);
    } catch (err) {
      console.error(err);
      message.error("Failed to fetch manager data.");
    }
  };

  const openPackModal = (record) => {
    setCurrentPackOrder(record);
    packForm.setFieldsValue({ partner_id: record.DeliveryPartnerID || undefined });
    setIsPackModalVisible(true);
  };

  const handlePack = async (values) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/manager/orders/update`, {
        order_id: currentPackOrder.OrderID,
        status: "Packed",
        partner_id: values.partner_id
      });
      message.success("Order marked as Packed and Partner Assigned!");
      setIsPackModalVisible(false);
      fetchData();
    } catch (err) {
      message.error("Failed to update status");
    }
  };

  const handleDelivered = async (orderId) => {
      try {
        await axios.post(`http://${window.location.hostname}:5000/manager/orders/update`, {
          order_id: orderId,
          status: "Delivered"
        });
        message.success("Order Delivery Completed!");
        fetchData();
      } catch (err) {
        message.error("Failed to update status to Delivered");
      }
  };

  const addEmployee = async (values) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/manager/employees`, {
        ...values,
        StoreID: user.StoreID
      });
      message.success("Employee Added");
      setIsEmpModalVisible(false);
      empForm.resetFields();
      fetchData();
    } catch (err) {
      message.error("Failed to add employee");
    }
  };

  const removeEmployee = async (id) => {
    try {
      await axios.delete(`http://${window.location.hostname}:5000/manager/employees/${id}`);
      message.success("Employee removed");
      fetchData();
    } catch (err) {
      message.error("Failed to remove employee");
    }
  };

  const openRestockModal = (record) => {
    setCurrentRestockProduct(record);
    restockForm.resetFields();
    setIsRestockModalVisible(true);
  };

  const handleRestock = async (values) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/manager/inventory/restock`, {
        store_id: user.StoreID,
        product_id: currentRestockProduct.ProductID,
        quantity_added: values.quantity_added
      });
      message.success("Stock updated successfully");
      setIsRestockModalVisible(false);
      fetchData();
    } catch (err) {
       message.error("Failed to restock");
    }
  };

  const openDisposeModal = (record) => {
    setCurrentDisposeProduct(record);
    disposeForm.resetFields();
    setIsDisposeModalVisible(true);
  };

  const handleDisposeRestock = async (values) => {
    try {
       await axios.post(`http://${window.location.hostname}:5000/manager/dispose-restock`, {
          store_id: user.StoreID,
          product_id: currentDisposeProduct.ProductID,
          new_quantity: values.new_quantity,
          new_expiry_date: values.new_expiry_date
       });
       message.success("Disposed and restocked!");
       setIsDisposeModalVisible(false);
       fetchData();
    } catch(e) { message.error("Error restocking"); }
  };

  const handleFlashSale = async (record) => {
    try {
       await axios.post(`http://${window.location.hostname}:5000/manager/flash-sale`, {
          product_id: record.ProductID
       });
       message.success("Flash Sale Launched!");
       fetchData();
    } catch(e) { message.error("Error launching flash sale"); }
  };

  const openComboModal = (record) => {
    setCurrentComboProduct(record);
    comboForm.resetFields();
    setIsComboModalVisible(true);
  };

  const handleComboCreate = async (values) => {
    try {
      const pids = [currentComboProduct.ProductID, ...values.bundled_products];
      await axios.post(`http://${window.location.hostname}:5000/manager/create-expiry-combo`, {
        combo_name: `Special Flash Deal: ${currentComboProduct.ProductName} Bundle`,
        product_ids: pids
      });
      message.success("Combo created successfully!");
      setIsComboModalVisible(false);
    } catch(e) { message.error("Failed to create combo"); }
  };

  const alertColumns = [
    { title: "Product ID", dataIndex: "ProductID", key: "ProductID" },
    { title: "Product Name", dataIndex: "ProductName", key: "ProductName" },
    { title: "Quantity Remaining", dataIndex: "Quantity", key: "Quantity", 
      render: (val) => <Tag color="red">{val} left</Tag> 
    },
    { title: "Action", key: "action", render: (_, record) => (
        <Button size="small" type="primary" onClick={() => openRestockModal(record)}>Restock</Button>
    )}
  ];

  const orderColumns = [
    { title: "Order ID", dataIndex: "OrderID", key: "OrderID" },
    { title: "Date", dataIndex: "OrderDateTime", key: "OrderDateTime" },
    { title: "Partner Status", dataIndex: "DeliveryPartnerID", key: "DeliveryPartnerID",
       render: (val) => {
          if (!val) return <Tag color="red" style={{fontWeight: 'bold'}}>Needs Assignment</Tag>;
          const partner = partners.find(p => p.partnerid === val);
          return <Tag color="blue">{partner ? `${partner.Name} (${val})` : `Partner ${val}`}</Tag>;
       }
    },
    { title: "Status", dataIndex: "OrderStatus", key: "OrderStatus",
      render: (val, record) => {
        let tagColor = val === "Placed" ? "orange" : val === "Packed" ? "blue" : "green";
        if (val === "Placed" && (new Date() - new Date(record.OrderDateTime)) > 600000) {
           tagColor = "red";
        }
        return <Tag color={tagColor}>{val}</Tag>;
      }
    },
    { title: "Amount", dataIndex: "TotalBillAmount", key: "TotalBillAmount", render: (val) => `₹${val}` },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <Space>
          {record.OrderStatus === "Placed" && 
              <Button type="primary" onClick={() => openPackModal(record)}>Mark as Packed</Button>}
          {record.OrderStatus === "Packed" && 
              <Button onClick={() => handleDelivered(record.OrderID)} style={{borderColor: 'green', color: 'green'}}>Complete Delivery</Button>}
        </Space>
      )
    }
  ];

  const empColumns = [
    { title: "ID", dataIndex: "EmployeeID", key: "EmployeeID" },
    { title: "Name", dataIndex: "Name", key: "Name" },
    { title: "Role", dataIndex: "Role", key: "Role" },
    { title: "Action", key: "action", render: (_, record) => (
      <Button danger onClick={() => removeEmployee(record.EmployeeID)}>Remove</Button>
    )}
  ];

  const filteredInventory = categoryFilter === "All" 
    ? fullInventory 
    : fullInventory.filter(item => item.CategoryName === categoryFilter);

  const fullInventoryColumns = [
    { title: "ID", dataIndex: "ProductID", key: "ProductID" },
    { title: "Name", dataIndex: "ProductName", key: "ProductName" },
    { title: "Category", dataIndex: "CategoryName", key: "CategoryName", render: (c) => c || 'N/A' },
    { title: "Current Stock", dataIndex: "QuantityRemaining", key: "QuantityRemaining" },
    { title: "Price", dataIndex: "Price", key: "Price", render: (p) => `₹${p}` },
    { title: "Expiry Date", dataIndex: "expiry_date", key: "expiry_date", render: (d) => d ? new Date(d).toLocaleDateString() : 'N/A' },
  ];

  const expiryWatchList = [...fullInventory]
    .filter(item => {
      if (!item.expiry_date) return false;
      const daysDiff = (new Date(item.expiry_date) - new Date()) / (1000 * 60 * 60 * 24);
      return daysDiff <= 30;
    })
    .sort((a, b) => new Date(a.expiry_date) - new Date(b.expiry_date));

  const expiryColumns = [
    { title: "Product Name", dataIndex: "ProductName", key: "ProductName" },
    { title: "Stock", dataIndex: "QuantityRemaining", key: "QuantityRemaining" },
    { title: "Expiry Date", dataIndex: "expiry_date", key: "expiry_date", 
      render: (d) => {
        const isExpired = new Date(d) < new Date();
        return <Tag color={isExpired ? "red" : "gold"}>{new Date(d).toLocaleDateString()}</Tag>;
      }
    },
    { title: "Action", key: "action", render: (_, record) => {
        const daysDiff = (new Date(record.expiry_date) - new Date()) / (1000 * 60 * 60 * 24);
        if (daysDiff <= 0) {
            return <Button size="small" danger onClick={() => openDisposeModal(record)}>Dispose & Restock</Button>;
        } else if (daysDiff <= 15) {
            return <Button size="small" style={{backgroundColor: 'orange', color: 'white', borderColor: 'orange'}} onClick={() => handleFlashSale(record)}>Launch 50% Flash Sale</Button>;
        } else {
            return <Button size="small" type="dashed" style={{borderColor: '#fadb14', color: '#d4b106'}} onClick={() => openComboModal(record)}>Convert to Combo</Button>;
        }
    }}
  ];

  return (
    <div style={{ padding: "20px" }}>
      <div className="blinkit-header" style={{ marginBottom: 20 }}>
        Store Manager - Welcome {user.Name}
      </div>

      <Tabs defaultActiveKey="1">
         <Tabs.TabPane tab="Inventory & Orders" key="1">
            <Card title="Low Stock Alerts (< 10)" style={{ marginBottom: 20, borderColor: '#ffccc7' }}>
              <Table dataSource={alerts} columns={alertColumns} rowKey="ProductID" size="small" />
            </Card>

            <Card title="Store Orders (Localized)">
              <Table dataSource={orders} columns={orderColumns} rowKey="OrderID" size="small"
                expandedRowRender={(record) => (
                  <ul>
                    {record.items.map((it, idx) => (
                      <li key={idx}>{it.ProductName} x {it.QuantityOrdered}</li>
                    ))}
                  </ul>
                )}
              />
            </Card>
         </Tabs.TabPane>

         <Tabs.TabPane tab="Full Inventory" key="2">
             <Card title="Available Products in Store" extra={
                 <Select defaultValue="All" style={{ width: 150 }} onChange={setCategoryFilter}>
                    <Select.Option value="All">All Categories</Select.Option>
                    <Select.Option value="Grocery">Grocery</Select.Option>
                    <Select.Option value="Electronics">Electronics</Select.Option>
                    <Select.Option value="Pharmaceutical">Pharmaceutical</Select.Option>
                 </Select>
             }>
                 <Table dataSource={filteredInventory} columns={fullInventoryColumns} rowKey="ProductID" size="small"/>
             </Card>
         </Tabs.TabPane>
         
         <Tabs.TabPane tab="Expiry Watch" key="3">
             <Card title="Products Expiring Soon (<= 30 days)">
                 <Table dataSource={expiryWatchList} columns={expiryColumns} rowKey="ProductID" size="small"/>
             </Card>
         </Tabs.TabPane>

         <Tabs.TabPane tab="Employee Management" key="4">
             <Button type="primary" style={{marginBottom: 15}} onClick={() => setIsEmpModalVisible(true)}>
                 + Add Employee
             </Button>
             <Card>
                <Table dataSource={employees} columns={empColumns} rowKey="EmployeeID" size="small"/>
             </Card>
         </Tabs.TabPane>
      </Tabs>
      
      <Button onClick={() => setPage(null)} style={{marginTop: 20}} type="primary" danger>Logout</Button>

      {/* MODALS */}
      <Modal title="Manual Partner Assignment (Pack Order)" open={isPackModalVisible} onCancel={() => setIsPackModalVisible(false)} onOk={() => packForm.submit()}>
          <div style={{ marginBottom: 15 }}>
              <p>Verify assignment for Order <strong>#{currentPackOrder?.OrderID}</strong></p>
          </div>
          <Form form={packForm} layout="vertical" onFinish={handlePack}>
              <Form.Item name="partner_id" label="Select Local Partner (Optional)" rules={[{ required: false }]}>
                  <Select placeholder="Assign / Override Partner" allowClear>
                     {partners.map(p => (
                         <Select.Option key={p.partnerid} value={p.partnerid} disabled={!p.is_available && p.partnerid !== packForm.getFieldValue('partner_id')}>
                             {p.Name} - {p.VehicleDetails} {p.is_available ? "(Available)" : "(Busy)"}
                         </Select.Option>
                     ))}
                  </Select>
              </Form.Item>
          </Form>
      </Modal>

      <Modal title="Add Store Employee" open={isEmpModalVisible} onCancel={() => setIsEmpModalVisible(false)} onOk={() => empForm.submit()}>
          <Form form={empForm} layout="vertical" onFinish={addEmployee}>
              <Form.Item name="Name" label="Employee Name" rules={[{ required: true }]}>
                  <Input />
              </Form.Item>
              <Form.Item name="Role" label="Store Role (e.g. Packer, Picker)" rules={[{ required: true }]}>
                  <Input />
              </Form.Item>
          </Form>
      </Modal>

      <Modal title="Restock Product (Low Stock)" open={isRestockModalVisible} onCancel={() => setIsRestockModalVisible(false)} onOk={() => restockForm.submit()}>
          <div style={{ marginBottom: 15 }}>
              <p style={{ margin: 0 }}><strong>Product:</strong> {currentRestockProduct?.ProductName}</p>
              <p style={{ margin: 0 }}><strong>Current Stock:</strong> <Tag color="blue">{currentRestockProduct?.Quantity}</Tag></p>
          </div>
          <Form form={restockForm} layout="vertical" onFinish={handleRestock}>
              <Form.Item name="quantity_added" label="Quantity to Add (+)" rules={[{ required: true, message: 'Please input quantity to add' }]}>
                  <InputNumber min={1} style={{ width: '100%' }} />
              </Form.Item>
          </Form>
      </Modal>

      <Modal title="Dispose & Re-Stock Fresh Goods" open={isDisposeModalVisible} onCancel={() => setIsDisposeModalVisible(false)} onOk={() => disposeForm.submit()}>
          <p>Product: <strong>{currentDisposeProduct?.ProductName}</strong></p>
          <Form form={disposeForm} layout="vertical" onFinish={handleDisposeRestock}>
              <Form.Item name="new_quantity" label="Fresh Quantity Amount" rules={[{ required: true }]}>
                  <InputNumber min={0} style={{ width: '100%' }} />
              </Form.Item>
              <Form.Item name="new_expiry_date" label="New Official Expiry Date" rules={[{ required: true }]}>
                  <Input type="date" />
              </Form.Item>
          </Form>
      </Modal>

      <Modal title="Bundle Expiry Product" open={isComboModalVisible} onCancel={() => setIsComboModalVisible(false)} onOk={() => comboForm.submit()}>
          <p>Primary Item: <strong>{currentComboProduct?.ProductName}</strong></p>
          <Form form={comboForm} layout="vertical" onFinish={handleComboCreate}>
              <Form.Item name="bundled_products" label="Select Items to Bundle" rules={[{ required: true }]}>
                  <Select mode="multiple" placeholder="Select products" style={{ width: '100%' }}>
                      {fullInventory.filter(p => p.ProductID !== currentComboProduct?.ProductID && p.QuantityRemaining > 0).map(p => (
                          <Select.Option key={p.ProductID} value={p.ProductID}>{p.ProductName} (Stock: {p.QuantityRemaining})</Select.Option>
                      ))}
                  </Select>
              </Form.Item>
          </Form>
      </Modal>
    </div>
  );
}

export default ManagerInventory;
