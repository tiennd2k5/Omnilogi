import { useEffect, useState } from 'react';
import axiosClient from '../api/axiosClient';

function ProductManager() {
    const [products, setProducts] = useState([]);
    const [statusFilter, setStatusFilter] = useState('All');
    const [searchFilter, setSearchFilter] = useState('');
    const [categoryIdFilter, setCategoryIdFilter] = useState('');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingId, setEditingId] = useState(null);
    const [form, setForm] = useState({
        category_id: '1',
        name: '',
        desc: '',
        brand: '',
        image_url: '',
        status: 'Pending',
        created_by_id: ''
    });

    const fetchProducts = async (
        nextStatusFilter = statusFilter,
        nextCategoryIdFilter = categoryIdFilter,
        nextSearchFilter = searchFilter
    ) => {
        try {
            const res = await axiosClient.get('/products', {
                params: {
                    status: nextStatusFilter === 'All' ? null : nextStatusFilter,
                    search: nextSearchFilter || null,
                    category_id: nextCategoryIdFilter || null
                }
            });
            setProducts(res.data.data || []);
        } catch (error) {
            console.error(error);
        }
    };

    useEffect(() => {
        let ignore = false;

        const loadProducts = async () => {
            try {
                const res = await axiosClient.get('/products', {
                    params: {
                        status: statusFilter === 'All' ? null : statusFilter,
                        search: searchFilter || null,
                        category_id: categoryIdFilter || null
                    }
                });
                if (!ignore) {
                    setProducts(res.data.data || []);
                }
            } catch (error) {
                console.error(error);
            }
        };

        loadProducts();
        return () => {
            ignore = true;
        };
    }, [statusFilter, categoryIdFilter]);

    const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

    const openAddModal = () => {
        setEditingId(null);
        setForm({ category_id: '1', name: '', desc: '', brand: '', image_url: '', status: 'Pending', created_by_id: '' });
        setIsModalOpen(true);
    };

    const openEditModal = async (id) => {
        try {
            const res = await axiosClient.get(`/products/${id}`);
            const product = res.data.data;
            setForm({
                category_id: product.Category_ID || '1',
                name: product.Name,
                desc: product.Description,
                brand: product.Brand,
                image_url: product.image_url,
                status: product.status,
                created_by_id: product.Created_by_ID || ''
            });
            setEditingId(id);
            setIsModalOpen(true);
        } catch {
            alert('Không lấy được dữ liệu sản phẩm');
        }
    };

    const handleSave = async () => {
        try {
            if (editingId) {
                await axiosClient.put(`/products/${editingId}`, {
                    category_id: form.category_id,
                    name: form.name,
                    desc: form.desc,
                    brand: form.brand,
                    image_url: form.image_url,
                    status: form.status
                });
                alert('Cập nhật thành công!');
            } else {
                await axiosClient.post('/products', {
                    ...form,
                    created_by_id: form.created_by_id ? parseInt(form.created_by_id, 10) : null
                });
                alert('Thêm thành công!');
            }
            setIsModalOpen(false);
            fetchProducts();
        } catch {
            alert('Lỗi, vui lòng kiểm tra lại dữ liệu');
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Bạn có chắc muốn xóa sản phẩm này?')) return;
        try {
            await axiosClient.delete(`/products/${id}`);
            fetchProducts();
        } catch {
            alert('Lỗi khi xóa sản phẩm');
        }
    };

    return (
        <div style={containerStyle}>
            <div style={headerCard}>
                <h2 style={{ color: '#1e293b', margin: 0, fontSize: '24px', fontWeight: '600' }}>Quản lý Sản Phẩm</h2>
                <button onClick={openAddModal} style={addBtnStyle}>+ Thêm sản phẩm</button>
            </div>

            <div style={filterCard}>
                <select value={categoryIdFilter} onChange={(e) => setCategoryIdFilter(e.target.value)} style={inputStyle}>
                    <option value="">Tất cả danh mục</option>
                    <option value="1">Điện tử</option>
                    <option value="2">Thời trang</option>
                    <option value="3">Thực phẩm</option>
                    <option value="4">Gia dụng</option>
                    <option value="5">Sách</option>
                </select>
                <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} style={inputStyle}>
                    <option value="All">Tất cả trạng thái</option>
                    <option value="Approved">Đang bán</option>
                    <option value="Pending">Chờ duyệt</option>
                    <option value="Rejected">Từ chối</option>
                </select>
                <input type="text" placeholder="Tìm kiếm sản phẩm..." value={searchFilter} onChange={(e) => setSearchFilter(e.target.value)} style={{ ...inputStyle, flex: 1 }} />
                <button onClick={fetchProducts} style={btnStyle}>Lọc dữ liệu</button>
            </div>

            <div style={tableCard}>
                <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '14px' }}>
                    <thead>
                        <tr>
                            <th style={thStyle}>ID</th>
                            <th style={thStyle}>Ảnh</th>
                            <th style={thStyle}>Tên & Thương hiệu</th>
                            <th style={thStyle}>Danh mục</th>
                            <th style={thStyle}>Trạng thái</th>
                            <th style={{ ...thStyle, textAlign: 'center' }}>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        {products.map((product) => (
                            <tr key={product.Product_ID} style={trStyle}>
                                <td style={tdStyle}>{product.Product_ID}</td>
                                <td style={tdStyle}>
                                    <img src={product.image_url} alt="sp" style={imageStyle} onError={(e) => { e.target.src = 'https://via.placeholder.com/48'; }} />
                                </td>
                                <td style={tdStyle}>
                                    <div style={{ fontWeight: '600', color: '#1e293b', marginBottom: '4px' }}>{product.Ten_San_Pham || product.Name}</div>
                                    <span style={{ color: '#64748b', fontSize: '13px' }}>{product.Thuong_Hieu}</span>
                                </td>
                                <td style={tdStyle}>
                                    <span style={badgeStyle}>{product.Danh_Muc}</span>
                                </td>
                                <td style={tdStyle}>
                                    <span style={{
                                        ...statusBadgeStyle,
                                        background: (product.Trang_Thai || product.status) === 'Approved' ? '#dcfce7' : (product.Trang_Thai || product.status) === 'Rejected' ? '#fee2e2' : '#fef3c7',
                                        color: (product.Trang_Thai || product.status) === 'Approved' ? '#166534' : (product.Trang_Thai || product.status) === 'Rejected' ? '#991b1b' : '#92400e'
                                    }}>
                                        {product.Trang_Thai || product.status}
                                    </span>
                                </td>
                                <td style={{ ...tdStyle, textAlign: 'center' }}>
                                    <button onClick={() => openEditModal(product.Product_ID)} style={{ ...actionBtn, background: '#f59e0b', color: '#fff', marginRight: '8px' }}>Sửa</button>
                                    <button onClick={() => handleDelete(product.Product_ID)} style={{ ...actionBtn, background: '#ef4444', color: '#fff' }}>Xóa</button>
                                </td>
                            </tr>
                        ))}
                        {products.length === 0 && (
                            <tr>
                                <td colSpan="6" style={{ padding: '30px', textAlign: 'center', color: '#94a3b8' }}>
                                    Không có dữ liệu sản phẩm.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {isModalOpen && (
                <div style={overlayStyle} onClick={() => setIsModalOpen(false)}>
                    <div style={popupStyle} onClick={(e) => e.stopPropagation()}>
                        <h3 style={{ marginTop: 0, marginBottom: '24px', color: '#0f172a', fontSize: '20px', borderBottom: '1px solid #e2e8f0', paddingBottom: '12px' }}>
                            {editingId ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'}
                        </h3>
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                            {!editingId && (
                                <div style={formGroup}>
                                    <label style={labelStyle}>ID Quản lý cửa hàng (Người tạo)</label>
                                    <input type="number" name="created_by_id" value={form.created_by_id} onChange={handleChange} style={inputStyle} />
                                </div>
                            )}

                            <div style={formGroup}>
                                <label style={labelStyle}>Danh mục</label>
                                <select name="category_id" value={form.category_id} onChange={handleChange} style={inputStyle}>
                                    <option value="1">Điện tử</option>
                                    <option value="2">Thời trang</option>
                                    <option value="3">Thực phẩm</option>
                                    <option value="4">Gia dụng</option>
                                    <option value="5">Sách</option>
                                </select>
                            </div>

                            <div style={formGroup}>
                                <label style={labelStyle}>Tên sản phẩm</label>
                                <input name="name" value={form.name} onChange={handleChange} style={inputStyle} />
                            </div>

                            <div style={formGroup}>
                                <label style={labelStyle}>Thương hiệu</label>
                                <input name="brand" value={form.brand} onChange={handleChange} style={inputStyle} />
                            </div>

                            <div style={formGroup}>
                                <label style={labelStyle}>Link ảnh (URL)</label>
                                <input name="image_url" value={form.image_url} onChange={handleChange} style={inputStyle} />
                            </div>

                            <div style={formGroup}>
                                <label style={labelStyle}>Trạng thái</label>
                                <select name="status" value={form.status} onChange={handleChange} style={inputStyle}>
                                    <option value="Pending">Chờ duyệt</option>
                                    <option value="Approved">Đã duyệt</option>
                                    <option value="Rejected">Từ chối</option>
                                </select>
                            </div>

                            <div style={formGroup}>
                                <label style={labelStyle}>Mô tả</label>
                                <textarea name="desc" value={form.desc} onChange={handleChange} style={{ ...inputStyle, height: '80px', resize: 'vertical' }} />
                            </div>
                        </div>
                        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '28px' }}>
                            <button onClick={() => setIsModalOpen(false)} style={{ ...btnStyle, background: '#f1f5f9', color: '#475569', border: '1px solid #cbd5e1' }}>Hủy</button>
                            <button onClick={handleSave} style={{ ...btnStyle, background: '#3b82f6', boxShadow: '0 2px 4px rgba(59, 130, 246, 0.3)' }}>Lưu thông tin</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}

const containerStyle = { fontFamily: "'Inter', 'Segoe UI', sans-serif", padding: '24px', background: '#f8fafc', minHeight: '100vh', color: '#334155' };
const headerCard = { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' };
const filterCard = { display: 'flex', gap: '16px', marginBottom: '24px', background: '#ffffff', padding: '20px', borderRadius: '12px', boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: '1px solid #e2e8f0', flexWrap: 'wrap' };
const tableCard = { background: '#ffffff', borderRadius: '12px', boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: '1px solid #e2e8f0', overflow: 'hidden' };
const inputStyle = { padding: '10px 14px', border: '1px solid #cbd5e1', borderRadius: '8px', outline: 'none', fontSize: '14px', color: '#1e293b', background: '#fff', transition: 'border 0.2s' };
const btnStyle = { padding: '10px 20px', background: '#3b82f6', color: '#fff', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '500', fontSize: '14px', transition: 'opacity 0.2s' };
const addBtnStyle = { padding: '10px 20px', background: '#10b981', color: '#fff', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '600', fontSize: '14px', boxShadow: '0 2px 4px rgba(16, 185, 129, 0.2)' };
const thStyle = { padding: '16px', background: '#f1f5f9', color: '#475569', fontWeight: '600', borderBottom: '2px solid #e2e8f0', textTransform: 'uppercase', fontSize: '12px', letterSpacing: '0.5px' };
const tdStyle = { padding: '16px', verticalAlign: 'middle' };
const trStyle = { borderBottom: '1px solid #f1f5f9' };
const actionBtn = { border: 'none', padding: '8px 12px', borderRadius: '6px', cursor: 'pointer', fontSize: '13px', fontWeight: '500' };
const imageStyle = { width: '48px', height: '48px', objectFit: 'cover', borderRadius: '8px', border: '1px solid #e2e8f0' };
const badgeStyle = { background: '#f1f5f9', color: '#475569', padding: '4px 10px', borderRadius: '20px', fontSize: '12px', fontWeight: '500' };
const statusBadgeStyle = { padding: '4px 10px', borderRadius: '20px', fontSize: '12px', fontWeight: '600', display: 'inline-block' };
const formGroup = { display: 'flex', flexDirection: 'column', gap: '6px' };
const labelStyle = { fontSize: '13px', fontWeight: '600', color: '#475569' };
const overlayStyle = { position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(30, 41, 59, 0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, backdropFilter: 'blur(4px)' };
const popupStyle = { background: '#ffffff', padding: '32px', borderRadius: '16px', width: '500px', maxWidth: '90%', boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)', maxHeight: '90vh', overflowY: 'auto' };

export default ProductManager;
