import axios from "axios";
import { useEffect, useState } from "react";
import { Card, Button, Input, Select, Typography, Row, Col, message, Drawer, List, Space, Tag } from "antd";
import { ShoppingCartOutlined, LogoutOutlined, DeleteOutlined, WalletOutlined, PlusOutlined, ThunderboltOutlined } from "@ant-design/icons";

const { Title, Text } = Typography;

function Products({ user, setPage, setUser }) {
  const [products, setProducts] = useState([]);
  const [recommendations, setRecommendations] = useState([]);
  const [trending, setTrending] = useState([]);
  const [combos, setCombos] = useState([]);
  const [cart, setCart] = useState([]);
  const [myBaskets, setMyBaskets] = useState([]);
  const [wallet, setWallet] = useState(user.WalletBalance || 0);

  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("All");

  // Drawer State
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [activeCombo, setActiveCombo] = useState(null);
  const [activeComboItems, setActiveComboItems] = useState([]);
  // Product Search inside Drawer
  const [drawerSearch, setDrawerSearch] = useState("");

  useEffect(() => {
    fetchGlobalData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    fetchDynamicData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [category]);

  const fetchGlobalData = async () => {
    try {
      const [resProd, resCart, resBaskets, resWallet] = await Promise.all([
        axios.get(`http://${window.location.hostname}:5000/customer/products`),
        axios.get(`http://${window.location.hostname}:5000/customer/cart/${user.CustomerID}`),
        axios.get(`http://${window.location.hostname}:5000/customer/custombaskets/${user.CustomerID}`),
        axios.get(`http://${window.location.hostname}:5000/customer/wallet/${user.CustomerID}`)
      ]);
      setProducts(resProd.data);
      setCart(resCart.data);
      setMyBaskets(resBaskets.data);
      setWallet(resWallet.data.WalletBalance);
    } catch(e) {}
  };

  const fetchDynamicData = async () => {
    const query = category !== "All" ? `?category_id=${category}` : "";
    try {
      const [resRec, resTrend, resCombos] = await Promise.all([
        axios.get(`http://${window.location.hostname}:5000/customer/recommendations/${user.CustomerID}${query}`),
        axios.get(`http://${window.location.hostname}:5000/customer/trending${query}`),
        axios.get(`http://${window.location.hostname}:5000/customer/combos${query}`)
      ]);
      setRecommendations(resRec.data);
      setTrending(resTrend.data);
      setCombos(resCombos.data);
    } catch(e) {}
  };

  const getCartQuantity = (pid) => {
    const item = cart.find(c => c.ProductID === pid);
    return item ? item.Quantity : 0;
  };

  const updateCart = async (pid, qty) => {
    try {
      if (qty === 0) {
        await axios.post(`http://${window.location.hostname}:5000/customer/cart/remove`, { customer_id: user.CustomerID, product_id: pid });
      } else {
        const currentQty = getCartQuantity(pid);
        if (currentQty === 0) {
          await axios.post(`http://${window.location.hostname}:5000/customer/cart/add`, { customer_id: user.CustomerID, product_id: pid, qty });
        } else {
          await axios.post(`http://${window.location.hostname}:5000/customer/cart/update`, { customer_id: user.CustomerID, product_id: pid, qty });
        }
      }
      
      const resCart = await axios.get(`http://${window.location.hostname}:5000/customer/cart/${user.CustomerID}`);
      setCart(resCart.data);
    } catch (err) {
      message.error("Error updating cart");
    }
  };

  const openComboDrawer = (combo) => {
      setActiveCombo(combo);
      setActiveComboItems([...combo.items]);
      setIsDrawerOpen(true);
  };

  const addToActiveCombo = (prd) => {
      if (!activeComboItems.find(p => p.ProductID === prd.ProductID)){
          setActiveComboItems(prev => [...prev, prd]);
      }
  };

  const removeFromActiveCombo = (pid) => {
      setActiveComboItems(prev => prev.filter(p => p.ProductID !== pid));
  };

  const commitActiveComboToCart = async () => {
      if (activeComboItems.length === 0) return message.warning("Basket is empty!");
      try {
        for (const item of activeComboItems) {
            const currentQty = getCartQuantity(item.ProductID);
            if (currentQty === 0) {
                await axios.post(`http://${window.location.hostname}:5000/customer/cart/add`, { customer_id: user.CustomerID, product_id: item.ProductID, qty: 1 });
            } else {
                await axios.post(`http://${window.location.hostname}:5000/customer/cart/update`, { customer_id: user.CustomerID, product_id: item.ProductID, qty: currentQty + 1 });
            }
        }
        message.success("Basket added to cart!");
        const resCart = await axios.get(`http://${window.location.hostname}:5000/customer/cart/${user.CustomerID}`);
        setCart(resCart.data);
        setIsDrawerOpen(false);
      } catch(e) { message.error("Failed"); }
  };

  const saveAsMyBasket = async () => {
      if (activeComboItems.length === 0) return message.warning("Basket is empty!");
      const name = prompt("Name your Custom Basket:");
      if (!name) return;
      try {
          const pids = activeComboItems.map(p => p.ProductID);
          await axios.post(`http://${window.location.hostname}:5000/customer/custombaskets/save`, {
              customer_id: user.CustomerID,
              basket_name: name,
              product_ids: pids
          });
          message.success("Basket Saved!");
          setIsDrawerOpen(false);
          const resBaskets = await axios.get(`http://${window.location.hostname}:5000/customer/custombaskets/${user.CustomerID}`);
          setMyBaskets(resBaskets.data);
      } catch(e) { message.error("Database error"); }
  };

  const filteredProducts = products.filter(p => {
    const matchSearch = p.ProductName.toLowerCase().includes(search.toLowerCase());
    const matchCategory = category === "All" || p.CategoryID === (category === "Grocery" ? 1 : category === "Pharmaceutical" ? 2 : 3);
    return matchSearch && matchCategory;
  });

  const flashSaleProducts = filteredProducts.filter(p => Boolean(p.is_flash_sale) === true || p.is_flash_sale === 1);

  const renderProductCard = (p) => {
    const qty = getCartQuantity(p.ProductID);
    const isFlash = Boolean(p.is_flash_sale);
    
    return (
      <Card 
        key={p.ProductID} 
        size="small" 
        style={{ width: 180, flexShrink: 0, marginRight: 15, borderColor: isFlash ? '#ff4d4f' : '#d9d9d9' }}
        actions={[ 
          qty > 0 ? (
            <Space key="add">
                <Button size="small" onClick={() => updateCart(p.ProductID, qty - 1)}>-</Button>
                <span>{qty}</span>
                <Button size="small" type="primary" onClick={() => updateCart(p.ProductID, qty + 1)}>+</Button>
            </Space>
          ) : (
            <Button key="add" type="primary" onClick={() => updateCart(p.ProductID, 1)}>Add</Button>
          )
        ]}
      >
        <Card.Meta 
          title={p.ProductName} 
          description={
             isFlash ? (
               <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                 <Text delete type="secondary" style={{ fontSize: '12px' }}>₹{p.original_price}</Text>
                 <Text strong type="danger" style={{ fontSize: '16px' }}>₹{p.Price}</Text>
               </div>
             ) : (
               <span>₹{p.Price}</span>
             )
          } 
        />
        {isFlash && <Tag color="red" style={{ marginTop: 8 }} icon={<ThunderboltOutlined/>}>50% OFF</Tag>}
      </Card>
    );
  };

  return (
    <div style={{ padding: "20px" }}>
      <div className="blinkit-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <span>Welcome, {user.Name}</span>
        <div style={{ display: 'flex', alignItems: 'center', gap: 15 }}>
          <Tag color="green" style={{ fontSize: 16, padding: '4px 10px' }} icon={<WalletOutlined />}>
              Wallet: ₹{wallet}
          </Tag>
          <Button type="default" onClick={() => setPage("orders")}>View Orders</Button>
          <Button type="primary" icon={<ShoppingCartOutlined />} onClick={() => setPage("cart")}>Cart ({cart.length})</Button>
          <Button danger icon={<LogoutOutlined />} onClick={() => setUser(null)}>Logout</Button>
        </div>
      </div>

      <div style={{ marginBottom: 20, display: "flex", gap: "10px" }}>
        <Input.Search 
          placeholder="Search products..." 
          value={search} 
          onChange={(e) => setSearch(e.target.value)} 
          style={{ width: 300 }} 
        />
        <Select value={category} onChange={setCategory} style={{ width: 150 }}>
          <Select.Option value="All">All Categories</Select.Option>
          <Select.Option value="Grocery">Grocery</Select.Option>
          <Select.Option value="Pharmaceutical">Pharmaceutical</Select.Option>
          <Select.Option value="Electronics">Electronics</Select.Option>
        </Select>
      </div>

      {flashSaleProducts.length > 0 && (
         <div style={{ marginBottom: 30, backgroundColor: '#fff2e8', padding: '15px', borderRadius: '8px', border: '2px solid #ff4d4f' }}>
             <Title level={4} style={{ color: '#cf1322', display: 'flex', alignItems: 'center', gap: '10px' }}>
                 <ThunderboltOutlined /> EMERGENCY DEALS - FLASH SALE!
             </Title>
             <div style={{ display: "flex", overflowX: "auto", paddingBottom: "10px" }}>
                 {flashSaleProducts.map(renderProductCard)}
             </div>
         </div>
      )}

      <div style={{ marginBottom: 30 }}>
        <Title level={4}>🎁 Filtered Smart Baskets</Title>
        <div style={{ display: "flex", overflowX: "auto", paddingBottom: "10px" }}>
          {combos.map((combo) => (
             <Card 
               hoverable
               key={combo.ComboID} 
               size="small" 
               style={{ width: 220, flexShrink: 0, marginRight: 15, cursor: 'pointer', border: '1px solid #1677ff' }}
               onClick={() => openComboDrawer(combo)}
             >
               <Card.Meta title={combo.ComboName} description={`Click to Customize (${combo.items.length} items)`} />
             </Card>
          ))}
        </div>
      </div>

      {myBaskets.length > 0 && (
         <div style={{ marginBottom: 30 }}>
           <Title level={4}>🛒 Saved "My Baskets"</Title>
           <div style={{ display: "flex", overflowX: "auto", paddingBottom: "10px" }}>
             {myBaskets.map((b) => (
                <Card 
                  hoverable
                  key={b.BasketID} 
                  size="small" 
                  style={{ width: 220, flexShrink: 0, marginRight: 15, cursor: 'pointer', border: '1px solid #52c41a' }}
                  onClick={() => openComboDrawer({ ComboName: b.BasketName, items: b.items })}
                >
                  <Card.Meta title={b.BasketName} description={`${b.items.length} items`} />
                </Card>
             ))}
           </div>
         </div>
      )}

      <div style={{ marginBottom: 30 }}>
        <Title level={4}>🔥 Trending in {category}</Title>
        <div style={{ display: "flex", overflowX: "auto", paddingBottom: "10px" }}>
          {trending.map(renderProductCard)}
        </div>
      </div>

      <div style={{ marginBottom: 30 }}>
        <Title level={4}>✨ Recommended for You</Title>
        <div style={{ display: "flex", overflowX: "auto", paddingBottom: "10px" }}>
          {recommendations.map(renderProductCard)}
        </div>
      </div>

      <Title level={4}>All Products</Title>
      <Row gutter={[16, 16]}>
        {filteredProducts.map(p => (
          <Col xs={24} sm={12} md={8} lg={6} xl={4} key={p.ProductID}>
             {renderProductCard(p)}
          </Col>
        ))}
      </Row>

      {/* CUSTOMIZATION DRAWER */}
      <Drawer
        title={activeCombo?.ComboName || "Customize Basket"}
        placement="right"
        width={400}
        onClose={() => setIsDrawerOpen(false)}
        open={isDrawerOpen}
        extra={
            <Button type="primary" onClick={() => commitActiveComboToCart()}>Add to Cart</Button>
        }
      >
          <Title level={5}>Current Items in Basket</Title>
          <List
            size="small"
            dataSource={activeComboItems}
            renderItem={item => (
              <List.Item
                actions={[<Button type="text" danger icon={<DeleteOutlined />} onClick={() => removeFromActiveCombo(item.ProductID)} />]}
              >
                <Text strong>{item.ProductName}</Text> <br/>
                <Text type="secondary">₹{item.Price}</Text>
              </List.Item>
            )}
            style={{ marginBottom: 20 }}
          />
          
          <Button block style={{marginBottom: 20}} onClick={() => saveAsMyBasket()}>Save as My Basket</Button>

          <Title level={5}>Add More Products</Title>
          <Input.Search 
            placeholder="Search to add..." 
            value={drawerSearch}
            onChange={(e) => setDrawerSearch(e.target.value)}
            style={{ marginBottom: 10 }}
          />
          <div style={{ maxHeight: 300, overflowY: 'auto' }}>
            <List
               size="small"
               dataSource={products.filter(p => drawerSearch && p.ProductName.toLowerCase().includes(drawerSearch.toLowerCase()))}
               renderItem={item => (
                   <List.Item
                       actions={[<Button type="text" style={{color: '#1677ff'}} icon={<PlusOutlined />} onClick={() => addToActiveCombo(item)} />]}
                   >
                       {item.ProductName} - ₹{item.Price}
                   </List.Item>
               )}
            />
          </div>
      </Drawer>
    </div>
  );
}

export default Products;