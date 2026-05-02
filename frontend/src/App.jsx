import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Home from './pages/Home';
import ProductManager from './pages/ProductManager';
import CustomerTier from './pages/CustomerTier';
import StoreRevenue from './pages/StoreRevenue';

function App() {
  return (
    <Router>
      <div style={{ fontFamily: 'system-ui, -apple-system, sans-serif', backgroundColor: '#f4f7f6', minHeight: '100vh' }}>
        <nav style={{ background: '#2980b9', color: '#fff', padding: '15px 40px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', position: 'sticky', top: 0, zIndex: 100, boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
          <div style={{ fontSize: '22px', fontWeight: 'bold', letterSpacing: '0.5px' }}>
            OmniLogi
          </div>
          <div style={{ display: 'flex', gap: '30px', fontWeight: '500', fontSize: '15px' }}>
            <Link to="/" style={{ color: '#fff', textDecoration: 'none' }}>Trang chủ</Link>
            <Link to="/products" style={{ color: '#fff', textDecoration: 'none' }}>Quản lý Sản phẩm</Link>
            <Link to="/tier" style={{ color: '#fff', textDecoration: 'none' }}>Hạng Thành viên</Link>
            <Link to="/revenue" style={{ color: '#fff', textDecoration: 'none' }}>Thống kê Cửa hàng</Link>
          </div>
        </nav>

        <div style={{ padding: '30px 40px', maxWidth: '1200px', margin: '0 auto' }}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/products" element={<ProductManager />} />
            <Route path="/tier" element={<CustomerTier />} />
            <Route path="/revenue" element={<StoreRevenue />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
