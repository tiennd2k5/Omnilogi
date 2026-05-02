import { useState } from 'react';
import axiosClient from '../api/axiosClient';

const MOCK_USERS = [
    { id: 11, username: 'na_shop', name: 'Cao Thị Na' },
    { id: 12, username: 'oanh_buy', name: 'Lý Văn Oanh' },
    { id: 13, username: 'phuong_shop', name: 'Tô Thị Phương' },
    { id: 14, username: 'quan_buy', name: 'Hà Minh Quân' },
    { id: 15, username: 'rong_shop', name: 'Mã Thị Rồng' }
];

function CustomerTier() {
    const [searchType, setSearchType] = useState('id');
    const [inputValue, setInputValue] = useState('');
    const [selectedId, setSelectedId] = useState('');
    const [tierData, setTierData] = useState(null);
    const [showSuggestions, setShowSuggestions] = useState(false);

    const filteredUsers = MOCK_USERS.filter((user) =>
        user.username.toLowerCase().startsWith(inputValue.toLowerCase())
    );

    const handleSelectUser = (user) => {
        setInputValue(user.username);
        setSelectedId(user.id);
        setShowSuggestions(false);
    };

    const checkTier = async () => {
        const idToCheck = searchType === 'id' ? inputValue : selectedId;
        if (!idToCheck) {
            alert('Vui lòng nhập hoặc chọn khách hàng hợp lệ!');
            return;
        }

        try {
            const res = await axiosClient.get(`/customers/${idToCheck}/tier`);
            setTierData(res.data.data);
        } catch {
            alert('Không tìm thấy hạng cho khách hàng này');
            setTierData(null);
        }
    };

    return (
        <div style={pageContainer}>
            <div style={cardStyle}>
                <h2 style={headerTitle}>Tra cứu Hạng Thành viên</h2>

                <div style={radioContainer}>
                    <label style={radioLabelStyle}>
                        <input
                            type="radio"
                            checked={searchType === 'id'}
                            onChange={() => { setSearchType('id'); setInputValue(''); setTierData(null); }}
                            style={radioInputStyle}
                        />
                        Tìm theo ID
                    </label>
                    <label style={radioLabelStyle}>
                        <input
                            type="radio"
                            checked={searchType === 'username'}
                            onChange={() => { setSearchType('username'); setInputValue(''); setTierData(null); }}
                            style={radioInputStyle}
                        />
                        Tìm theo Username
                    </label>
                </div>

                <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                    <div style={{ display: 'flex', gap: '12px' }}>
                        <input
                            type={searchType === 'id' ? 'number' : 'text'}
                            placeholder={searchType === 'id' ? 'Nhập ID (VD: 11)' : 'Nhập Username (VD: na_shop)'}
                            value={inputValue}
                            onChange={(e) => {
                                setInputValue(e.target.value);
                                if (searchType === 'username') setShowSuggestions(true);
                                if (searchType === 'id') setSelectedId(e.target.value);
                            }}
                            onFocus={() => { if (searchType === 'username') setShowSuggestions(true); }}
                            style={{ ...inputStyle, flex: 1 }}
                        />
                        <button onClick={checkTier} style={btnStyle}>Tra cứu</button>
                    </div>

                    {searchType === 'username' && showSuggestions && inputValue && (
                        <div style={autocompleteDropdownStyle}>
                            {filteredUsers.length > 0 ? filteredUsers.map((user) => (
                                <div
                                    key={user.id}
                                    onClick={() => handleSelectUser(user)}
                                    style={suggestionItemStyle}
                                    onMouseEnter={(e) => { e.currentTarget.style.backgroundColor = '#f1f5f9'; }}
                                    onMouseLeave={(e) => { e.currentTarget.style.backgroundColor = '#ffffff'; }}
                                >
                                    <strong style={{ color: '#1e293b' }}>{user.username}</strong>
                                    <span style={{ color: '#64748b', fontSize: '13px', marginLeft: '6px' }}>({user.name})</span>
                                </div>
                            )) : (
                                <div style={{ padding: '12px 16px', color: '#64748b', fontSize: '14px' }}>Không tìm thấy Username phù hợp.</div>
                            )}
                        </div>
                    )}
                </div>

                {tierData && (
                    <div style={resultCardStyle}>
                        <div style={{ fontSize: '14px', color: '#475569', marginBottom: '8px', fontWeight: '500' }}>
                            Hạng hiện tại của khách hàng:
                        </div>
                        <div style={{ fontSize: '28px', fontWeight: '700', color: '#2563eb' }}>
                            {tierData.tier || tierData.Membership_Status}
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}

const pageContainer = { fontFamily: "'Inter', 'Segoe UI', sans-serif", padding: '40px 20px', background: '#f8fafc', minHeight: '100vh', display: 'flex', justifyContent: 'center', alignItems: 'flex-start', color: '#334155' };
const cardStyle = { background: '#ffffff', width: '100%', maxWidth: '520px', padding: '32px', borderRadius: '16px', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03)', border: '1px solid #e2e8f0' };
const headerTitle = { color: '#0f172a', margin: '0 0 24px 0', fontSize: '22px', fontWeight: '600', textAlign: 'center' };
const radioContainer = { display: 'flex', gap: '24px', marginBottom: '20px', justifyContent: 'center' };
const radioLabelStyle = { display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', fontSize: '14px', fontWeight: '500', color: '#475569' };
const radioInputStyle = { cursor: 'pointer', margin: 0 };
const inputStyle = { padding: '12px 16px', border: '1px solid #cbd5e1', borderRadius: '8px', outline: 'none', fontSize: '14px', color: '#1e293b', background: '#fff', transition: 'border 0.2s', width: '100%' };
const btnStyle = { padding: '12px 24px', background: '#3b82f6', color: '#fff', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: '500', fontSize: '14px', transition: 'opacity 0.2s', boxShadow: '0 2px 4px rgba(59, 130, 246, 0.3)', whiteSpace: 'nowrap' };
const autocompleteDropdownStyle = { position: 'absolute', top: '100%', left: 0, right: '110px', marginTop: '4px', background: '#ffffff', border: '1px solid #cbd5e1', borderRadius: '8px', zIndex: 10, maxHeight: '200px', overflowY: 'auto', boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)' };
const suggestionItemStyle = { padding: '12px 16px', cursor: 'pointer', borderBottom: '1px solid #f1f5f9', transition: 'background-color 0.15s' };
const resultCardStyle = { marginTop: '32px', padding: '24px', background: '#eff6ff', border: '1px solid #bfdbfe', borderRadius: '12px', textAlign: 'center' };

export default CustomerTier;
