import { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';

function Home() {
    const [products, setProducts] = useState([]);
    const [status, setStatus] = useState('All');
    const [search, setSearch] = useState('');
    const [categoryId, setCategoryId] = useState('');
    const [selectedProduct, setSelectedProduct] = useState(null);

    const fetchProducts = async (nextStatus = status, nextCategoryId = categoryId, nextSearch = search) => {
        try {
            const res = await axiosClient.get('/products', {
                params: {
                    status: nextStatus === 'All' ? null : nextStatus,
                    search: nextSearch || null,
                    category_id: nextCategoryId || null
                }
            });
            setProducts(res.data.data || []);
        } catch (error) {
            console.error('Lỗi lấy sản phẩm', error);
        }
    };

    useEffect(() => {
        let ignore = false;

        const loadProducts = async () => {
            try {
                const res = await axiosClient.get('/products', {
                    params: {
                        status: status === 'All' ? null : status,
                        search: search || null,
                        category_id: categoryId || null
                    }
                });
                if (!ignore) {
                    setProducts(res.data.data || []);
                }
            } catch (error) {
                console.error('Lỗi lấy sản phẩm', error);
            }
        };

        loadProducts();
        return () => {
            ignore = true;
        };
    }, [status, categoryId]);

    const showRecommendations = async (id, e) => {
        e.stopPropagation();
        try {
            const res = await axiosClient.get(`/products/${id}/recommendations`);
            alert(`Sản phẩm gợi ý mua kèm:\n\n${res.data.data.recommendations || res.data.data}`);
        } catch {
            alert('Chưa có gợi ý nào cho sản phẩm này.');
        }
    };

    return (
        <div style={containerStyle}>
            <div style={headerContainer}>
                <h2 style={headerTitle}>Danh sách Sản Phẩm</h2>
            </div>

            <div style={filterCard}>
                <select value={categoryId} onChange={(e) => setCategoryId(e.target.value)} style={inputStyle}>
                    <option value="">Tất cả danh mục</option>
                    <option value="1">Điện tử</option>
                    <option value="2">Thời trang</option>
                    <option value="3">Thực phẩm</option>
                    <option value="4">Gia dụng</option>
                    <option value="5">Sách</option>
                </select>

                <select value={status} onChange={(e) => setStatus(e.target.value)} style={inputStyle}>
                    <option value="All">Tất cả trạng thái</option>
                    <option value="Approved">Đang bán</option>
                    <option value="Pending">Chờ duyệt</option>
                    <option value="Rejected">Từ chối</option>
                </select>

                <input
                    type="text"
                    placeholder="Tìm kiếm sản phẩm..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    style={{ ...inputStyle, flex: 1 }}
                />
                <button onClick={fetchProducts} style={btnStyle}>Tìm kiếm</button>
            </div>

            <div style={gridStyle}>
                {products.length > 0 ? products.map((product) => (
                    <div key={product.Product_ID} style={cardStyle}>
                        <img
                            src={product.image_url || 'https://via.placeholder.com/200'}
                            alt={product.Ten_San_Pham}
                            style={cardImageStyle}
                            onError={(e) => { e.target.src = 'https://via.placeholder.com/200?text=No+Image'; }}
                        />
                        <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', height: 'calc(100% - 220px)' }}>
                            <div style={productTitleStyle}>{product.Ten_San_Pham}</div>
                            <div style={{ marginTop: 'auto' }}>
                                <button onClick={() => setSelectedProduct(product)} style={outlineBtnStyle}>Xem chi tiết</button>
                                <div style={{ textAlign: 'center', marginTop: '12px' }}>
                                    <button onClick={(e) => showRecommendations(product.Product_ID, e)} style={linkBtnStyle}>Gợi ý mua kèm</button>
                                </div>
                            </div>
                        </div>
                    </div>
                )) : (
                    <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '60px 20px', color: '#94a3b8', background: '#fff', borderRadius: '12px', border: '1px solid #e2e8f0' }}>
                        Không tìm thấy sản phẩm nào phù hợp.
                    </div>
                )}
            </div>

            {selectedProduct && (
                <div style={overlayStyle} onClick={() => setSelectedProduct(null)}>
                    <div style={popupStyle} onClick={(e) => e.stopPropagation()}>
                        <h3 style={popupHeaderStyle}>Chi tiết sản phẩm</h3>
                        <div style={{ display: 'flex', gap: '24px', marginTop: '20px' }}>
                            <img
                                src={selectedProduct.image_url}
                                alt="img"
                                style={popupImageStyle}
                                onError={(e) => { e.target.src = 'https://via.placeholder.com/150'; }}
                            />
                            <div style={popupDetailsStyle}>
                                <p style={detailRowStyle}><span style={detailLabelStyle}>Mã SP:</span> {selectedProduct.Product_ID}</p>
                                <p style={detailRowStyle}><span style={detailLabelStyle}>Tên:</span> <strong style={{ color: '#0f172a' }}>{selectedProduct.Ten_San_Pham}</strong></p>
                                <p style={detailRowStyle}><span style={detailLabelStyle}>Thương hiệu:</span> {selectedProduct.Thuong_Hieu || 'Đang cập nhật'}</p>
                                <p style={detailRowStyle}><span style={detailLabelStyle}>Danh mục:</span> <span style={badgeStyle}>{selectedProduct.Danh_Muc}</span></p>
                                <p style={detailRowStyle}>
                                    <span style={detailLabelStyle}>Trạng thái:</span>
                                    <span style={{
                                        ...statusBadgeStyle,
                                        background: selectedProduct.Trang_Thai === 'Approved' ? '#dcfce7' : selectedProduct.Trang_Thai === 'Rejected' ? '#fee2e2' : '#fef3c7',
                                        color: selectedProduct.Trang_Thai === 'Approved' ? '#166534' : selectedProduct.Trang_Thai === 'Rejected' ? '#991b1b' : '#92400e'
                                    }}>
                                        {selectedProduct.Trang_Thai}
                                    </span>
                                </p>
                                <p style={{ ...detailRowStyle, flexDirection: 'column', alignItems: 'flex-start', gap: '8px', marginTop: '12px' }}>
                                    <span style={detailLabelStyle}>Mô tả:</span>
                                    <span style={{ color: '#475569', lineHeight: '1.6' }}>{selectedProduct.Mo_Ta || 'Chưa có mô tả chi tiết cho sản phẩm này.'}</span>
                                </p>
                            </div>
                        </div>
                        <div style={{ textAlign: 'right', marginTop: '32px' }}>
                            <button onClick={() => setSelectedProduct(null)} style={{ ...btnStyle, background: '#f1f5f9', color: '#475569', border: '1px solid #cbd5e1', boxShadow: 'none' }}>Đóng lại</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}

const containerStyle = { fontFamily: "'Inter', 'Segoe UI', sans-serif", padding: '24px', background: '#f8fafc', minHeight: '100vh', color: '#334155' };
const headerContainer = { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' };
const headerTitle = { color: '#1e293b', margin: 0, fontSize: '24px', fontWeight: '600' };
const filterCard = { display: 'flex', gap: '16px', marginBottom: '32px', background: '#ffffff', padding: '20px', borderRadius: '12px', boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: '1px solid #e2e8f0', flexWrap: 'wrap' };
const inputStyle = { padding: '10px 14px', border: '1px solid #cbd5e1', borderRadius: '8px', outline: 'none', fontSize: '14px', color: '#1e293b', background: '#fff', transition: 'border 0.2s' };
const btnStyle = { padding: '10px 20px', background: '#3b82f6', color: '#fff', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '500', fontSize: '14px', transition: 'opacity 0.2s', boxShadow: '0 2px 4px rgba(59, 130, 246, 0.3)' };
const gridStyle = { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: '24px' };
const cardStyle = { background: '#ffffff', borderRadius: '12px', overflow: 'hidden', border: '1px solid #e2e8f0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)', display: 'flex', flexDirection: 'column', transition: 'transform 0.2s, box-shadow 0.2s' };
const cardImageStyle = { width: '100%', height: '220px', objectFit: 'cover', borderBottom: '1px solid #f1f5f9' };
const productTitleStyle = { fontSize: '15px', color: '#1e293b', marginBottom: '16px', fontWeight: '600', lineHeight: '1.4', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' };
const outlineBtnStyle = { padding: '10px 15px', background: '#fff', color: '#3b82f6', border: '1px solid #3b82f6', borderRadius: '8px', cursor: 'pointer', fontSize: '14px', fontWeight: '500', width: '100%', transition: 'background 0.2s' };
const linkBtnStyle = { background: 'none', color: '#64748b', border: 'none', cursor: 'pointer', fontSize: '13px', textDecoration: 'underline', fontWeight: '500' };
const overlayStyle = { position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(30, 41, 59, 0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, backdropFilter: 'blur(4px)' };
const popupStyle = { background: '#ffffff', padding: '32px', borderRadius: '16px', width: '550px', maxWidth: '90%', boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)', maxHeight: '90vh', overflowY: 'auto' };
const popupHeaderStyle = { marginTop: 0, marginBottom: '0', color: '#0f172a', fontSize: '20px', borderBottom: '1px solid #e2e8f0', paddingBottom: '16px', fontWeight: '600' };
const popupImageStyle = { width: '160px', height: '160px', objectFit: 'cover', borderRadius: '12px', border: '1px solid #e2e8f0' };
const popupDetailsStyle = { flex: 1, fontSize: '14px', display: 'flex', flexDirection: 'column', gap: '10px' };
const detailRowStyle = { margin: 0, display: 'flex', alignItems: 'center', color: '#334155' };
const detailLabelStyle = { width: '90px', fontWeight: '600', color: '#64748b', flexShrink: 0 };
const badgeStyle = { background: '#f1f5f9', color: '#475569', padding: '4px 10px', borderRadius: '20px', fontSize: '12px', fontWeight: '500' };
const statusBadgeStyle = { padding: '4px 10px', borderRadius: '20px', fontSize: '12px', fontWeight: '600', display: 'inline-block' };

export default Home;
