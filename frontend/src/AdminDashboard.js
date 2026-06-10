import React, { useEffect, useState } from "react";
import axios from "axios";
import { Table, Card, Row, Col, Statistic, Button, message, Tabs, Modal, Form, Input, Tag, Select, InputNumber } from "antd";
import { PlusOutlined } from "@ant-design/icons";

function AdminDashboard({ user, setPage }) {
  const [analytics, setAnalytics] = useState({ revenue: 0, orders: 0, customers: 0 });
  const [users, setUsers] = useState([]);
  const [products, setProducts] = useState([]);
  const [storeHealth, setStoreHealth] = useState([]);
  const [auditLogs, setAuditLogs] = useState([]);
  const [employees, setEmployees] = useState([]);
  const [darkStores, setDarkStores] = useState([]);
  
  // Modals visibility
  const [isProductModalVisible, setIsProductModalVisible] = useState(false);
  const [isUserModalVisible, setIsUserModalVisible] = useState(false);
  const [isStoreModalVisible, setIsStoreModalVisible] = useState(false);
  const [isEmployeeModalVisible, setIsEmployeeModalVisible] = useState(false);

  // States
  const [editingProduct, setEditingProduct] = useState(null);
  const [userRoleContext, setUserRoleContext] = useState("customer");
  
  const [productForm] = Form.useForm();
  const [userForm] = Form.useForm();
  const [storeForm] = Form.useForm();
  const [employeeForm] = Form.useForm();

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const [resAnal, resUsers, resProd, resHealth, resAudit, resEmp, resStores] = await Promise.all([
        axios.get(`http://${window.location.hostname}:5000/admin/analytics`),
        axios.get(`http://${window.location.hostname}:5000/admin/users`),
        axios.get(`http://${window.location.hostname}:5000/admin/products`),
        axios.get(`http://${window.location.hostname}:5000/admin/store-health`),
        axios.get(`http://${window.location.hostname}:5000/admin/audit-log`),
        axios.get(`http://${window.location.hostname}:5000/admin/employees`),
        axios.get(`http://${window.location.hostname}:5000/admin/darkstores`)
      ]);
      setAnalytics(resAnal.data);
      setUsers(resUsers.data);
      setProducts(resProd.data);
      setStoreHealth(resHealth.data);
      setAuditLogs(resAudit.data);
      setEmployees(resEmp.data);
      setDarkStores(resStores.data);
    } catch (err) {
      console.error(err);
      message.error("Failed to fetch admin data.");
    }
  };

  // ---- PRODUCT LOGIC ----
  const deleteProduct = async (id) => {
    try {
      await axios.delete(`http://${window.location.hostname}:5000/admin/products/${id}`);
      message.success("Product deleted successfully");
      fetchData();
    } catch (err) { message.error("Error deleting product"); }
  };

  const handleProductSubmit = async (values) => {
    try {
      if (editingProduct) {
        await axios.put(`http://${window.location.hostname}:5000/admin/products/${editingProduct.ProductID}`, values);
        message.success("Product updated!");
      } else {
        await axios.post(`http://${window.location.hostname}:5000/admin/products`, values);
        message.success("Product added!");
      }
      setIsProductModalVisible(false);
      fetchData();
    } catch (err) { message.error("Failed to save product"); }
  };

  // ---- USER LOGIC ----
  const deleteUser = async (role, id) => {
    try {
      await axios.delete(`http://${window.location.hostname}:5000/admin/users/${role}/${id}`);
      message.success("User deleted successfully");
      fetchData();
    } catch (err) { message.error("Error deleting user"); }
  };

  const handleUserSubmit = async (values) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/admin/users/${userRoleContext}`, values);
      message.success("User added successfully. Wallets initialized where applicable!");
      setIsUserModalVisible(false);
      fetchData();
    } catch (err) { message.error(err.response?.data?.error || "Error adding user"); }
  };

  // ---- STORE LOGIC ----
  const deleteDarkStore = async (id) => {
    try {
      await axios.delete(`http://${window.location.hostname}:5000/admin/darkstores/${id}`);
      message.success("Store deleted");
      fetchData();
    } catch (err) { message.error("Error deleting store"); }
  };

  const handleStoreSubmit = async (values) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/admin/darkstores`, values);
      message.success("Store added");
      setIsStoreModalVisible(false);
      fetchData();
    } catch (err) { message.error("Failed to add store"); }
  };

  // ---- EMPLOYEE LOGIC ----
  const deleteEmployee = async (id) => {
    try {
      await axios.delete(`http://${window.location.hostname}:5000/admin/employees/${id}`);
      message.success("Employee deleted");
      fetchData();
    } catch (err) { message.error("Error deleting employee"); }
  };

  const handleEmployeeSubmit = async (values) => {
    try {
      await axios.post(`http://${window.location.hostname}:5000/admin/employees`, values);
      message.success("Employee added");
      setIsEmployeeModalVisible(false);
      fetchData();
    } catch (err) { message.error("Failed to add employee"); }
  };


  // --- COLUMNS ---
  const storeHealthColumns = [
    { title: "Store Location", dataIndex: "StoreName", key: "StoreName" },
    { title: "Total Revenue", dataIndex: "TotalRevenue", key: "TotalRevenue", render: val => `₹${val}` },
    { title: "Active Pickers", dataIndex: "ActiveEmployees", key: "ActiveEmployees" },
    { title: "Action", key: "action", render: (_, r) => <Button danger onClick={() => deleteDarkStore(r.StoreID)}>Close Down</Button> }
  ];

  const productColumns = [
    { title: "ID", dataIndex: "ProductID", key: "ProductID" },
    { title: "Name", dataIndex: "ProductName", key: "ProductName" },
    { title: "Brand", dataIndex: "Brand", key: "Brand" },
    { title: "Price", dataIndex: "Price", key: "Price", render: (val) => `₹${val}` },
    {
      title: "Action",
      key: "action",
      render: (_, record) => (
        <>
            <Button onClick={() => { setEditingProduct(record); productForm.setFieldsValue(record); setIsProductModalVisible(true); }} style={{ marginRight: 8 }}>Edit</Button>
            <Button danger onClick={() => deleteProduct(record.ProductID)}>Delete</Button>
        </>
      ),
    },
  ];

  const userColumns = [
    { title: "Role", dataIndex: "Role", key: "Role", render: r => <Tag color="blue">{r}</Tag> },
    { title: "ID", dataIndex: "ID", key: "ID" },
    { title: "Name", dataIndex: "Name", key: "Name" },
    { title: "Email", dataIndex: "Email", key: "Email" },
    { title: "Phone", dataIndex: "PhoneNumber", key: "PhoneNumber" },
    { title: "Info", dataIndex: "Address", key: "Address" },
    { title: "Action", key: "action", render: (_, record) => (
         <Button danger onClick={() => deleteUser(record.Role, record.ID)}>Evict</Button>
    )}
  ];

  const empColumns = [
    { title: "ID", dataIndex: "EmployeeID", key: "EmployeeID" },
    { title: "Name", dataIndex: "Name", key: "Name" },
    { title: "Role", dataIndex: "Role", key: "Role" },
    { title: "Store assigned", dataIndex: "StoreLocation", key: "StoreLocation" },
    { title: "Action", key: "action", render: (_, record) => (
         <Button danger onClick={() => deleteEmployee(record.EmployeeID)}>Fire</Button>
    )}
  ];

  const auditColumns = [
    { title: "Transfer ID", dataIndex: "TransferID", key: "TransferID" },
    { title: "Date", dataIndex: "TransferDate", key: "TransferDate", render: (val) => new Date(val).toLocaleString() },
    { title: "Customer (Debited)", dataIndex: "CustomerName", key: "CustomerName" },
    { title: "Manager (Credited)", dataIndex: "ManagerName", key: "ManagerName" },
    { title: "Order ID", dataIndex: "OrderID", key: "OrderID", render: (val) => val ? `#${val}` : "N/A" },
    { title: "Amount", dataIndex: "Amount", key: "Amount", render: (val) => {
        const floatVal = parseFloat(val);
        return <Tag color={floatVal > 0 ? "green" : "red"}>{floatVal > 0 ? `+₹${floatVal}` : `-₹${Math.abs(floatVal)}`}</Tag>
    }}
  ];

  return (
    <div style={{ padding: "20px" }}>
      <div className="blinkit-header" style={{ marginBottom: 20 }}>
        Admin Control Center - Superuser {user.Name}
      </div>

      <Tabs defaultActiveKey="1" style={{ minHeight: 400 }}>
        <Tabs.TabPane tab="Analytics Overview" key="1">
            <Row gutter={16} style={{ marginBottom: 20 }}>
                <Col span={8}>
                <Card>
                    <Statistic title="Total Platform Revenue" value={analytics.revenue} prefix="₹" />
                </Card>
                </Col>
                <Col span={8}>
                <Card>
                    <Statistic title="Total Orders Executed" value={analytics.orders} />
                </Card>
                </Col>
                <Col span={8}>
                <Card>
                    <Statistic title="Registered Customers" value={analytics.customers} />
                </Card>
                </Col>
            </Row>
        </Tabs.TabPane>

        <Tabs.TabPane tab="Products" key="2">
            <Card title="Product Architecture" extra={<Button type="primary" icon={<PlusOutlined />} onClick={() => { setEditingProduct(null); productForm.resetFields(); setIsProductModalVisible(true); }}>Add Product</Button>}>
                <Table dataSource={products} columns={productColumns} rowKey="ProductID" />
            </Card>
        </Tabs.TabPane>

        <Tabs.TabPane tab="Users (Multi-Role)" key="3">
            <Card title="User Manifest" extra={
                 <Button type="primary" icon={<PlusOutlined />} onClick={() => { userForm.resetFields(); setIsUserModalVisible(true); }}>Add User</Button>
            }>
                <Table dataSource={users} columns={userColumns} rowKey={(record) => `${record.Role}-${record.ID}`} />
            </Card>
        </Tabs.TabPane>

        <Tabs.TabPane tab="Platform Employees" key="4">
            <Card title="Pickers & Packers" extra={<Button type="primary" icon={<PlusOutlined />} onClick={() => { employeeForm.resetFields(); setIsEmployeeModalVisible(true); }}>Hire Employee</Button>}>
                <Table dataSource={employees} columns={empColumns} rowKey="EmployeeID" />
            </Card>
        </Tabs.TabPane>

        <Tabs.TabPane tab="Dark Stores Network" key="5">
            <Card title="Store Infrastructure & Health" extra={<Button type="primary" icon={<PlusOutlined />} onClick={() => { storeForm.resetFields(); setIsStoreModalVisible(true); }}>Open Store</Button>}>
                <Table dataSource={storeHealth} columns={storeHealthColumns} rowKey="StoreName" />
            </Card>
        </Tabs.TabPane>

        <Tabs.TabPane tab="Wallet Audit Logs" key="6">
            <Table dataSource={auditLogs} columns={auditColumns} rowKey="TransferID" />
        </Tabs.TabPane>
      </Tabs>
      
      <Button onClick={() => setPage(null)} style={{marginTop: 20}} type="primary" danger>Logout</Button>

      {/* --- ADD PRODUCT MODAL --- */}
      <Modal title={editingProduct ? "Update Product" : "Create New Product"} open={isProductModalVisible} onCancel={() => setIsProductModalVisible(false)} onOk={() => productForm.submit()}>
           <Form form={productForm} onFinish={handleProductSubmit} layout="vertical">
               <Form.Item name="ProductName" label="Product Name" rules={[{required: true}]}><Input /></Form.Item>
               <Form.Item name="Brand" label="Brand"><Input /></Form.Item>
               <Form.Item name="CategoryID" label="Category" rules={[{required: true}]}>
                   <Select>
                       <Select.Option value={1}>Grocery</Select.Option>
                       <Select.Option value={2}>Pharmaceutical</Select.Option>
                       <Select.Option value={3}>Electronics</Select.Option>
                   </Select>
               </Form.Item>
               <Form.Item name="Price" label="Price" rules={[{required: true}]}><InputNumber style={{width:'100%'}} prefix="₹" /></Form.Item>

               {!editingProduct && (
                  <>
                  <Form.Item name="StoreIDs" label="Distribute to Stores (Optional)">
                      <Select mode="multiple" placeholder="Select dark stores to stock this item">
                          {darkStores.map(ds => <Select.Option key={ds.StoreID} value={ds.StoreID}>{ds.StoreLocation}</Select.Option>)}
                      </Select>
                  </Form.Item>
                  <Form.Item name="InitialQuantity" label="Initial Quantity (Per Selected Store)" initialValue={0}>
                      <InputNumber min={0} style={{width: '100%'}} />
                  </Form.Item>
                  </>
               )}
           </Form>
      </Modal>

      {/* --- ADD USER MODAL --- */}
      <Modal title="Create New System User" open={isUserModalVisible} onCancel={() => setIsUserModalVisible(false)} onOk={() => userForm.submit()}>
           <Form form={userForm} onFinish={handleUserSubmit} layout="vertical">
               <Form.Item name="Role" label="User Role" rules={[{required: true}]} initialValue="customer">
                   <Select onChange={(val) => setUserRoleContext(val)}>
                       <Select.Option value="customer">Customer</Select.Option>
                       <Select.Option value="Store Manager">Store Manager</Select.Option>
                       <Select.Option value="Delivery Partner">Delivery Partner</Select.Option>
                   </Select>
               </Form.Item>
               <Form.Item name="Name" label="Full Name" rules={[{required: true}]}><Input /></Form.Item>
               <Form.Item name="Email" label="Email Address" rules={[{required: true, type: 'email'}]}><Input /></Form.Item>
               <Form.Item name="PhoneNumber" label="Phone Number"><Input /></Form.Item>

               {userRoleContext === 'customer' && (
                  <Form.Item name="Address" label="Delivery Address"><Input.TextArea /></Form.Item>
               )}
               {userRoleContext === 'Store Manager' && (
                  <Form.Item name="StoreID" label="Assign Store (ID)" rules={[{required: true}]}>
                      <Select>
                          {darkStores.map(ds => <Select.Option key={ds.StoreID} value={ds.StoreID}>{ds.StoreLocation}</Select.Option>)}
                      </Select>
                  </Form.Item>
               )}
               {userRoleContext === 'Delivery Partner' && (
                  <Form.Item name="VehicleDetails" label="Vehicle Details (e.g., Bike Model)"><Input /></Form.Item>
               )}
           </Form>
      </Modal>

      {/* --- ADD EMPLOYEE MODAL --- */}
      <Modal title="Hire Employee" open={isEmployeeModalVisible} onCancel={() => setIsEmployeeModalVisible(false)} onOk={() => employeeForm.submit()}>
           <Form form={employeeForm} onFinish={handleEmployeeSubmit} layout="vertical">
               <Form.Item name="Name" label="Employee Name" rules={[{required: true}]}><Input /></Form.Item>
               <Form.Item name="Role" label="Job Role" rules={[{required: true}]} initialValue="Picker">
                    <Select>
                       <Select.Option value="Picker">Picker</Select.Option>
                       <Select.Option value="Packer">Packer</Select.Option>
                   </Select>
               </Form.Item>
               <Form.Item name="StoreID" label="Store Location" rules={[{required: true}]}>
                    <Select>
                        {darkStores.map(ds => <Select.Option key={ds.StoreID} value={ds.StoreID}>{ds.StoreLocation}</Select.Option>)}
                    </Select>
               </Form.Item>
           </Form>
      </Modal>

      {/* --- ADD STORE MODAL --- */}
      <Modal title="Open Dark Store" open={isStoreModalVisible} onCancel={() => setIsStoreModalVisible(false)} onOk={() => storeForm.submit()}>
           <Form form={storeForm} onFinish={handleStoreSubmit} layout="vertical">
               <Form.Item name="StoreLocation" label="Geographic Store Name/Area" rules={[{required: true}]}><Input /></Form.Item>
           </Form>
      </Modal>

    </div>
  );
}

export default AdminDashboard;
