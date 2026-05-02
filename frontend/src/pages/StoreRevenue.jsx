import { useState } from 'react';
import axiosClient from '../api/axiosClient';

function StoreRevenue() {
    const [filter, setFilter] = useState({ store_id: '', from_date: '', to_date: '', min_revenue: '' });
    const [stats, setStats] = useState([]);

    const handleChange = (e) => setFilter({ ...filter, [e.target.name]: e.target.value });

    const fetchStats = async () => {
        try {
            const res = await axiosClient.get('/stores/revenue-stats', {
                params: {
                    store_id: filter.store_id || null,
                    from_date: filter.from_date || null,
                    to_date: filter.to_date || null,
                    min_revenue: filter.min_revenue || null
                }
            });
            setStats(res.data.data || []);
        } catch (error) {
            console.error('Lỗi lấy thống kê', error);
            alert('Lỗi khi tải dữ liệu thống kê');
        }
    };

    return (
        <div style={containerStyle}>
            <div style={headerContainer}>
                <h2 style={headerTitle}>Thống Kê Doanh Thu Cửa Hàng</h2>
            </div>

            <div style={filterCard}>
                <div style={inputGroup}>
                    <label style={labelStyle}>ID Cửa hàng</label>
                    <input type="number" name="store_id" placeholder="Nhập ID..." value={filter.store_id} onChange={handleChange} style={inputStyle} />
                </div>

                <div style={inputGroup}>
                    <label style={labelStyle}>Từ ngày</label>
                    <input type="date" name="from_date" value={filter.from_date} onChange={handleChange} style={inputStyle} />
                </div>

                <div style={inputGroup}>
                    <label style={labelStyle}>Đến ngày</label>
                    <input type="date" name="to_date" value={filter.to_date} onChange={handleChange} style={inputStyle} />
                </div>

                <div style={inputGroup}>
                    <label style={labelStyle}>Doanh thu tối thiểu (VNĐ)</label>
                    <input type="number" name="min_revenue" placeholder="VD: 10000000" value={filter.min_revenue} onChange={handleChange} style={inputStyle} />
                </div>

                <div style={{ display: 'flex', alignItems: 'flex-end' }}>
                    <button onClick={fetchStats} style={btnStyle}>Lọc dữ liệu</button>
                </div>
            </div>

            <div style={tableCard}>
                <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '14px' }}>
                    <thead>
                        <tr>
                            <th style={thStyle}>Mã CH</th>
                            <th style={thStyle}>Tên Cửa hàng</th>
                            <th style={thStyle}>Quản lý</th>
                            <th style={{ ...thStyle, textAlign: 'center' }}>Tổng đơn Hoàn thành</th>
                            <th style={{ ...thStyle, textAlign: 'center' }}>SL đã bán</th>
                            <th style={{ ...thStyle, textAlign: 'right' }}>Doanh thu (VNĐ)</th>
                            <th style={{ ...thStyle, textAlign: 'center' }}>Đánh giá</th>
                        </tr>
                    </thead>
                    <tbody>
                        {stats.length > 0 ? stats.map((store, idx) => (
                            <tr key={idx} style={trStyle}>
                                <td style={tdStyle}>
                                    <span style={{ fontWeight: '600', color: '#1e293b' }}>{store.Ma_Cua_Hang}</span>
                                </td>
                                <td style={{ ...tdStyle, fontWeight: '500', color: '#334155' }}>{store.Ten_Cua_Hang}</td>
                                <td style={tdStyle}>{store.Quan_Ly}</td>
                                <td style={{ ...tdStyle, textAlign: 'center' }}>
                                    <span style={badgeStyle}>{store.Tong_Don_Hoan_Thanh}</span>
                                </td>
                                <td style={{ ...tdStyle, textAlign: 'center' }}>{store.Tong_SL_Da_Ban}</td>
                                <td style={{ ...tdStyle, textAlign: 'right', color: '#16a34a', fontWeight: '700' }}>
                                    {Number(store.Tong_Doanh_Thu_VND).toLocaleString('vi-VN')} đ
                                </td>
                                <td style={{ ...tdStyle, textAlign: 'center' }}>
                                    <span style={ratingBadge}>
                                        {store.Diem_DG_TB} <span style={{ color: '#f59e0b', marginLeft: '2px' }}>★</span>
                                    </span>
                                </td>
                            </tr>
                        )) : (
                            <tr>
                                <td colSpan="7" style={{ padding: '40px', textAlign: 'center', color: '#94a3b8' }}>
                                    Không có dữ liệu thống kê phù hợp với bộ lọc.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}

const containerStyle = { fontFamily: "'Inter', 'Segoe UI', sans-serif", padding: '24px', background: '#f8fafc', minHeight: '100vh', color: '#334155' };
const headerContainer = { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' };
const headerTitle = { color: '#1e293b', margin: 0, fontSize: '24px', fontWeight: '600' };
const filterCard = { display: 'flex', gap: '16px', marginBottom: '24px', background: '#ffffff', padding: '20px', borderRadius: '12px', boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: '1px solid #e2e8f0', flexWrap: 'wrap', alignItems: 'flex-start' };
const inputGroup = { display: 'flex', flexDirection: 'column', gap: '6px', flex: '1 1 200px' };
const labelStyle = { fontSize: '13px', fontWeight: '600', color: '#475569' };
const inputStyle = { padding: '10px 14px', border: '1px solid #cbd5e1', borderRadius: '8px', outline: 'none', fontSize: '14px', color: '#1e293b', background: '#fff', transition: 'border 0.2s', width: '100%', boxSizing: 'border-box' };
const btnStyle = { padding: '10px 24px', background: '#3b82f6', color: '#fff', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '500', fontSize: '14px', transition: 'opacity 0.2s', boxShadow: '0 2px 4px rgba(59, 130, 246, 0.3)', height: '42px' };
const tableCard = { background: '#ffffff', borderRadius: '12px', boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: '1px solid #e2e8f0', overflow: 'hidden' };
const thStyle = { padding: '16px', background: '#f1f5f9', color: '#475569', fontWeight: '600', borderBottom: '2px solid #e2e8f0', textTransform: 'uppercase', fontSize: '12px', letterSpacing: '0.5px' };
const tdStyle = { padding: '16px', verticalAlign: 'middle', borderBottom: '1px solid #f1f5f9' };
const trStyle = { transition: 'background-color 0.15s' };
const badgeStyle = { background: '#f1f5f9', color: '#475569', padding: '4px 10px', borderRadius: '20px', fontSize: '13px', fontWeight: '600' };
const ratingBadge = { background: '#fffbeb', color: '#b45309', padding: '4px 10px', borderRadius: '20px', fontSize: '13px', fontWeight: '600', border: '1px solid #fef3c7' };

export default StoreRevenue;
