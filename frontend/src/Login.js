import axios from "axios";
import { useState } from "react";
import { Card, Input, Button, Select, message, Typography } from "antd";

const { Title } = Typography;

function Login({ setUser }) {
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("Customer");

  const login = async () => {
    try {
      const res = await axios.post(`http://${window.location.hostname}:5000/auth/login`, {
        email,
        role
      });

      setUser(res.data);
      message.success("Login Success");
    } catch (err) {
      message.error("User not found");
    }
  };

  return (
    <div style={{ display: "flex", justifyContent: "center", alignItems: "center", height: "100vh", backgroundColor: "#f7f7f7" }}>
      <Card
        style={{ width: 400, boxShadow: "0 4px 12px rgba(0,0,0,0.1)" }}
        cover={<div style={{ backgroundColor: "#0c831f", padding: "20px", textAlign: "center", color: "white" }}>
          <Title level={3} style={{ color: "white", margin: 0 }}>MINITO</Title>
        </div>}
      >
        <div style={{ marginBottom: 15 }}>
          <label>Select Role</label>
          <Select value={role} onChange={setRole} style={{ width: "100%", marginTop: 5 }}>
            <Select.Option value="Customer">Customer</Select.Option>
            <Select.Option value="Admin">Admin</Select.Option>
            <Select.Option value="Store Manager">Store Manager</Select.Option>
            <Select.Option value="Delivery Partner">Delivery Partner</Select.Option>
          </Select>
        </div>

        <div style={{ marginBottom: 20 }}>
          <label>Email Address</label>
          <Input
            placeholder="Enter email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={{ marginTop: 5 }}
            onPressEnter={login}
          />
        </div>

        <Button type="primary" block onClick={login} size="large" style={{ backgroundColor: "#0c831f" }}>
          Login
        </Button>
      </Card>
    </div>
  );
}

export default Login;