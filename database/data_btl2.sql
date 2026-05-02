-- ============================================================
--  OmniLogi – Hệ thống sàn TMĐT tích hợp Logistics
--  Mô tả: Dữ liệu mẫu có ý nghĩa cho toàn bộ bảng (≥ 5 hàng)
-- ============================================================

USE Omnilogi;
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;


-- Tắt kiểm tra khóa ngoại để có thể TRUNCATE các bảng có quan hệ cha-con
SET FOREIGN_KEY_CHECKS = 0;

-- Nhóm thực thể yếu và bảng trung gian (Nên dọn trước)
TRUNCATE TABLE USER_PHONE;
TRUNCATE TABLE `USE`;
TRUNCATE TABLE SUB_CATEGORY;
TRUNCATE TABLE STORE_Categorical;
TRUNCATE TABLE STORE_PRODUCT;
TRUNCATE TABLE CART_ITEM;
TRUNCATE TABLE ORDER_ITEM;
TRUNCATE TABLE APPLIED_TO;
TRUNCATE TABLE TRACKING_HISTORY;
TRUNCATE TABLE REVIEW;

-- Nhóm thực thể giao dịch và vận hành
TRUNCATE TABLE PAYMENT;
TRUNCATE TABLE SHIPMENT;
TRUNCATE TABLE LOYALTY_POINTS;
TRUNCATE TABLE `ORDER`;
TRUNCATE TABLE CART;
TRUNCATE TABLE ADDRESS;

-- Nhóm thực thể chính (Master Data)
TRUNCATE TABLE PRODUCT;
TRUNCATE TABLE STORE;
TRUNCATE TABLE CATEGORY;
TRUNCATE TABLE VEHICLE;

-- Nhóm phân loại người dùng (Sub-types)
TRUNCATE TABLE ADMIN;
TRUNCATE TABLE STORE_MANAGER;
TRUNCATE TABLE CUSTOMER;
TRUNCATE TABLE DRIVER;

-- Thực thể gốc cuối cùng
TRUNCATE TABLE USER;

-- Bật lại kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 1. USER – Bỏ Admin_ID trước, cập nhật sau
-- ============================================================
INSERT INTO USER (User_ID, User_Role, User_name, `Password`, Email, First_name, Middle_name, Last_name,
                  Gender, Date_of_birth, User_status, Created_date, Admin_ID)
VALUES
-- 5 ADMIN
(1, 'Admin' , 'VanAn',    'hashed_pw1', 'admin.an@omnilogi.vn',     N'Nguyễn', N'Văn',   N'An',    'Male',  '1980-01-15','Active',    '2024-01-01 08:00:00', NULL),
(2, 'Admin' , 'ThiBinh',  'hashed_pw2', 'admin.binh@omnilogi.vn',   N'Trần',   N'Thị',   N'Bình',  'Female','1982-03-22','Active',    '2024-01-01 08:05:00', NULL),
(3, 'Admin' , 'HoangCuong', 'hashed_pw3', 'admin.cuong@omnilogi.vn',  N'Lê',     N'Hoàng', N'Cường', 'Male',  '1985-07-10','Active',    '2024-01-01 08:10:00', NULL),
(4, 'Admin' , 'MinhDuong', 'hashed_pw4', 'admin.duong@omnilogi.vn',  N'Phạm',   N'Minh',  N'Dương', 'Male',  '1979-11-05','Active',    '2024-01-01 08:15:00', NULL),
(5, 'Admin' , 'ThiEn',    'hashed_pw5', 'admin.en@omnilogi.vn',     N'Vũ',     N'Thị',   N'Én',    'Female','1983-09-18','Active',    '2024-01-01 08:20:00', NULL),
-- 5 STORE_MANAGER
(6, 'Manager' ,  'VanPhuc',  'hashed_pw6',  'mgr.phuc@gmail.com',   N'Hoàng', N'Văn',  N'Phúc',  'Male',  '1990-04-12','Active','2024-01-10 09:00:00', NULL),
(7, 'Manager' ,  'ThiGiang', 'hashed_pw7',  'mgr.giang@gmail.com',  N'Đặng',  N'Thị',  N'Giang', 'Female','1992-08-25','Active','2024-01-11 09:00:00', NULL),
(8, 'Manager' ,  'QuocHung',  'hashed_pw8',  'mgr.hung@gmail.com',   N'Bùi',   N'Quốc', N'Hùng',  'Male',  '1988-12-30','Active','2024-01-12 09:00:00', NULL),
(9, 'Manager' ,  'ThiLan',   'hashed_pw9',  'mgr.lan@gmail.com',    N'Ngô',   N'Thị',  N'Lan',   'Female','1994-02-14','Active','2024-01-13 09:00:00', NULL),
(10,'Manager' , 'VanMai',   'hashed_pw10', 'mgr.mai@gmail.com',    N'Đinh',  N'Văn',  N'Mai',   'Male',  '1991-06-08','Active','2024-01-14 09:00:00', NULL),
-- 5 CUSTOMER
(11, 'Customer' , 'na_shop',    'hashed_pw11', 'na.cust@gmail.com',    N'Cao',   N'Thị',  N'Na',    'Female','1998-03-20','Active','2024-02-01 10:00:00', NULL),
(12, 'Customer' , 'oanh_buy',   'hashed_pw12', 'oanh.cust@gmail.com',  N'Lý',    N'Văn',  N'Oanh',  'Male',  '2000-07-15','Active','2024-02-05 11:00:00', NULL),
(13, 'Customer' , 'phuong_shop','hashed_pw13', 'phuong.cust@gmail.com',N'Tô',    N'Thị',  N'Phương','Female','1996-11-28','Active','2024-02-10 14:00:00', NULL),
(14, 'Customer' , 'quan_buy',   'hashed_pw14', 'quan.cust@gmail.com',  N'Hà',    N'Minh', N'Quân',  'Male',  '1999-05-03','Active','2024-02-15 16:00:00', NULL),
(15, 'Customer' , 'rong_shop',  'hashed_pw15', 'rong.cust@gmail.com',  N'Mã',    N'Thị',  N'Rồng',  'Female','2001-09-12','Active','2024-02-20 09:30:00', NULL),

-- 5 DRIVER
(16, 'Driver' , 'VanTai', 'hashed_pw16', 'tai.drv@omnilogi.vn',  N'Sơn',   N'Văn',  N'Tài',   'Male',  '1992-04-18','Active','2024-01-05 07:00:00', NULL),
(17, 'Driver' , 'ThiUyen','hashed_pw17', 'uyen.drv@omnilogi.vn', N'Nguyễn',N'Thị',  N'Uyên',  'Female','1995-08-22','Active','2024-01-06 07:00:00', NULL),
(18, 'Driver' , 'VanVu',  'hashed_pw18', 'vu.drv@omnilogi.vn',   N'Trần',  N'Văn',  N'Vũ',    'Male',  '1993-01-30','Active','2024-01-07 07:00:00', NULL),
(19, 'Driver' , 'ThiXuan','hashed_pw19', 'xuan.drv@omnilogi.vn', N'Phan',  N'Thị',  N'Xuân',  'Female','1997-06-14','Active','2024-01-08 07:00:00', NULL),
(20, 'Driver' , 'VanYen', 'hashed_pw20', 'yen.drv@omnilogi.vn',  N'Dương', N'Văn',  N'Yên',   'Male',  '1990-10-25','Active','2024-01-09 07:00:00', NULL);

-- ============================================================
-- 2. ADMIN
-- ============================================================
INSERT INTO ADMIN (User_ID, Admin_level, Last_login) VALUES
(1, 5, '2025-04-10 08:00:00'),
(2, 4, '2025-04-10 08:30:00'),
(3, 3, '2025-04-09 17:00:00'),
(4, 3, '2025-04-08 10:00:00'),
(5, 2, '2025-04-10 11:00:00');

-- Cập nhật Supervisor (RB2: Admin cấp thấp chịu giám sát Admin cấp cao)
UPDATE USER SET Admin_ID = 1 WHERE User_ID IN (2,3,4,5);
UPDATE USER SET Admin_ID = 2 WHERE User_ID IN (6,7,8);
UPDATE USER SET Admin_ID = 3 WHERE User_ID IN (9,10);
UPDATE USER SET Admin_ID = 4 WHERE User_ID IN (11,12,13);
UPDATE USER SET Admin_ID = 5 WHERE User_ID IN (14,15,16,17,18,19,20);

-- ============================================================
-- 3. USER_PHONE
-- ============================================================
INSERT INTO USER_PHONE (User_ID, Phone) VALUES
(1,'0901234567'),(2,'0912345678'),(3,'0923456789'),(4,'0934567890'),(5,'0945678901'),
(6,'0956789012'),(7,'0967890123'),(8,'0978901234'),(9,'0989012345'),(10,'0901122334'),
(11,'0911223344'),(11,'0999888777'),  -- Customer 11 có 2 SĐT (đa trị)
(12,'0922334455'),(13,'0933445566'),(14,'0944556677'),(15,'0955667788'),
(16,'0966778899'),(17,'0977889900'),(18,'0988990011'),(19,'0901234560'),(20,'0912345670');

-- ============================================================
-- 4. STORE_MANAGER (Tax_code lưu tại đây theo schema)
-- ============================================================
INSERT INTO STORE_MANAGER (User_ID, Tax_code) VALUES
(6,  '0123456789'),
(7,  '0234567890'),
(8,  '0345678901'),
(9,  '0456789012'),
(10, '0567890123');

-- ============================================================
-- 5. CUSTOMER
-- ============================================================
INSERT INTO CUSTOMER (User_ID) VALUES (11),(12),(13),(14),(15);

-- ============================================================
-- 6. DRIVER
-- ============================================================
INSERT INTO DRIVER (User_ID, License_num, Vehicle_type, Driver_status, Total_deliveries) VALUES
(16,'BX001-2020','Xe máy',     'Available', 3),
(17,'BX002-2021','Xe máy',     'Busy',      3),
(18,'BX003-2019','Ô tô',      'Available',  1),
(19,'BX004-2022','Xe máy',     'Available', 2),
(20,'BX005-2020','Xe tải nhỏ','Busy',       3);

-- ============================================================
-- 7. VEHICLE
-- ============================================================
INSERT INTO VEHICLE (Vehicle_id, Plate_number, `Type`, `Status`) VALUES
(1,'59B1-12345','Xe máy',     'In use'),
(2,'59C2-23456','Xe máy',     'Available'),
(3,'51A3-34567','Ô tô',      'Available'),
(4,'51B4-45678','Xe tải nhỏ','In use'),
(5,'59D5-56789','Xe máy',     'In use'),
(6,'59E6-67890','Xe máy',     'Available');

-- ============================================================
-- 8. USE (Driver - Vehicle N-M)
-- ============================================================
INSERT INTO `USE` (User_ID, Vehicle_id) VALUES
(16,1),(16,2),
(17,1),(17,5),
(18,3),
(19,2),(19,6),
(20,4);

-- ============================================================
-- 9. CATEGORY
-- ============================================================
INSERT INTO CATEGORY (Category_ID, Category_name, Admin_ID) VALUES
(1, N'Điện tử',    1),
(2, N'Thời trang', 1),
(3, N'Thực phẩm',  2),
(4, N'Gia dụng',   2),
(5, N'Sách',       3);

-- ============================================================
-- 9.1. SUB_CATEGORY
-- ============================================================
INSERT INTO SUB_CATEGORY (Category_ID, Sub_category_ID, Sub_category_Name) VALUES
-- Category 1: Điện tử
(1, 1, N'Điện thoại'),
(1, 2, N'Laptop & Máy tính'),
(1, 3, N'Máy tính bảng'),
(1, 4, N'Phụ kiện'),
-- Category 2: Thời trang
(2, 1, N'Áo'),
(2, 2, N'Quần'),
(2, 3, N'Giày'),
-- Category 3: Thực phẩm
(3, 1, N'Đồ ăn vặt'),
(3, 2, N'Đồ uống');

-- ============================================================
-- 10. STORE
-- ============================================================
INSERT INTO STORE (Store_ID, Admin_ID, Manager_ID, `Name`, `Description`, Store_address) VALUES
(1, 1, 6,  N'TechViet Store',  N'Chuyên điện tử chính hãng Apple & Samsung',   N'123 Nguyễn Huệ, Q1, TP.HCM'),
(2, 1, 7,  N'Fashion Hub',     N'Thời trang nam nữ cao cấp',                    N'45 Lê Lợi, Q1, TP.HCM'),
(3, 2, 8,  N'Foods & More',    N'Thực phẩm sạch và đồ ăn vặt nhập khẩu',       N'78 Trần Hưng Đạo, Q5, TP.HCM'),
(4, 2, 9,  N'MobileZone',      N'Điện thoại & phụ kiện chính hãng',             N'200 Lý Thường Kiệt, Q10, TP.HCM'),
(5, 3, 10, N'LaptopPro',       N'Thiết bị máy tính và phụ kiện cho dân IT',        N'15 Hoàng Diệu 2, Thủ Đức, TP.HCM');

-- ============================================================
-- 10.1. STORE_Categorical (phân loại theo cửa hàng)
-- ============================================================
INSERT INTO STORE_Categorical (Store_ID, Categorical) VALUES
(1, N'Điện thoại & thiết bị Apple chính hãng'),
(1, N'Điện thoại Samsung chính hãng'),
(2, N'Thời trang nam'),
(2, N'Thời trang nữ'),
(3, N'Đồ ăn & đồ uống'),
(4, N'Điện thoại & phụ kiện'),
(5, N'Thiết bị máy tính & phụ kiện');

-- ============================================================
-- 11. PRODUCT
-- ============================================================
INSERT INTO PRODUCT (Product_ID, Category_ID, `Name`, `Description`, Brand, image_url, status, Created_by_ID) VALUES
(1, 1, 'iPhone 15 Pro Max 256GB', 'Chip A17 Pro, camera 48MP, viền titanium', 'Apple',
 'https://images.unsplash.com/photo-1695822822491-d92cee704368?w=500', 'Approved', 6),
(2, 1, 'Samsung Galaxy S24 Ultra', 'AI phone, camera 200MP, S-Pen', 'Samsung',
 'https://images.unsplash.com/photo-1709744722656-9b850470293f?w=500', 'Approved', 7),
(3, 1, 'MacBook Air M3', 'Laptop mỏng nhẹ, pin 18h', 'Apple',
 'https://images.unsplash.com/photo-1651241680016-cc9e407e7dc3?w=500', 'Pending', 6),
(4, 1, 'AirPods Pro 2', 'Tai nghe chống ồn chủ động', 'Apple',
 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=500', 'Pending', 6),
(5, 1, 'Sạc dự phòng 20000mAh', 'Sạc nhanh 65W', 'Xiaomi',
 'https://images.unsplash.com/photo-1614399113305-a127bb2ca893?w=500', 'Approved', NULL),
(6, 1, 'Cáp sạc Type-C', 'Hỗ trợ 100W', 'Baseus',
 'https://images.unsplash.com/photo-1660921436563-65ec990056e5?w=500', 'Approved', 8),
(7, 1, 'Ốp lưng iPhone', 'Chống sốc silicon', 'Apple',
 'https://images.unsplash.com/photo-1535157412991-2ef801c1748b?w=500', 'Approved', 7),
(8, 2, 'Áo thun basic nam', 'Cotton co giãn', 'Local Brand',
 'https://plus.unsplash.com/premium_photo-1673356302067-aac3b545a362?w=500', 'Approved', 9),
(9, 2, 'Quần jean slim fit', 'Co giãn nhẹ', 'Levis',
 'https://images.unsplash.com/photo-1475178626620-a4d074967452?w=500', 'Approved', 9),
(10, 2, 'Áo sơ mi nam', 'Chất linen thoáng mát', 'Zara',
 'https://plus.unsplash.com/premium_photo-1725075088969-73798c9b422c?w=500', 'Approved', NULL),
(11, 2, 'Áo hoodie unisex', 'Nỉ dày giữ ấm', 'H&M',
 'https://images.unsplash.com/photo-1616030257764-0fe6a2f05138?w=500', 'Approved', 9),
(12, 2, 'Giày sneaker trắng', 'Phong cách basic', 'Nike',
 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?w=500', 'Approved', 9),
(13, 3, 'Kẹo gấu Haribo', 'Nhập khẩu Đức', 'Haribo',
 'https://images.unsplash.com/photo-1606005600469-f012fe104a4d?w=500', 'Pending', 10),
(14, 3, 'Socola đen 85%', 'Socola cao cấp Bỉ', 'Godiva',
 'https://images.unsplash.com/photo-1604514813549-92e26bbae4f2?w=500', 'Approved', 10),
(15, 3, 'Snack Poca BBQ', 'Snack khoai tây', 'Poca',
 'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=500', 'Approved', 10),
(16, 3, 'Coca Cola 330ml', 'Nước giải khát có gas', 'Coca Cola',
 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=500', 'Approved', NULL),
(17, 3, 'Bánh Oreo', 'Bánh quy socola', 'Oreo',
 'https://images.unsplash.com/photo-1672753261221-608b9d15d597?w=500', 'Pending', 10),
(18, 1, 'Chuột không dây Logitech', 'Kết nối Bluetooth', 'Logitech',
 'https://images.unsplash.com/photo-1605773527852-c546a8584ea3?w=500', 'Approved', 8),
(19, 1, 'Bàn phím cơ RGB', 'Switch blue', 'Razer',
 'https://images.unsplash.com/photo-1626958390898-162d3577f293?w=500', 'Approved', 8),
(20, 1, 'Màn hình 27 inch', 'Full HD 144Hz', 'LG',
 'https://images.unsplash.com/photo-1570485071395-29b575ea3b4e?w=500', 'Approved', 7),
(21, 1, 'iPad Pro M4', 'Tablet cao cấp Apple', 'Apple',
 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500', 'Approved', NULL),
(22, 2, 'Áo khoác da', 'Phong cách biker', 'Zara',
 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500', 'Pending', 9),
(23, 3, 'Thực phẩm không rõ nguồn gốc', 'Không có chứng nhận an toàn vệ sinh thực phẩm', 'Unknown', 'https://images.unsplash.com/photo-1738618140037-09e11c8e644a?w=500', 'Rejected', 10),
(24, 1, 'Pin điện thoại kém chất lượng', 'Pin không rõ xuất xứ', 'NoBrand', 'https://images.unsplash.com/photo-1642801069630-bbb4d78061be?w=500', 'Rejected', 6);

-- ============================================================
-- 12. STORE_PRODUCT (SProduct_ID AUTO_INCREMENT → 1..10)
-- ============================================================
INSERT INTO STORE_PRODUCT (Store_ID, Product_ID, Price, Stock_quantity) VALUES
(1, 1, 32990000, 50),   -- TechViet Store – iPhone 15 Pro Max 256 GB
(4, 1, 33500000, 30),   -- MobileZone – iPhone 15 Pro Max 256 GB (cùng sản phẩm, khác store)
(1, 2, 22990000, 80),   -- TechViet Store – Samsung Galaxy S24 Ultra
(1, 6, 140000, 150), -- TechViet – Cáp sạc Type-C
(4, 2, 23100000, 40),   -- MobileZone – Samsung Galaxy S24 Ultra
(5, 5, 900000, 200),    -- LaptopPro – Sạc dự phòng 20000mAh
(4, 6, 150000, 300),    -- MobileZone – Cáp sạc Type-C
(4, 7, 120000, 150),    -- MobileZone – Ốp lưng iPhone
(5, 18, 850000, 100),   -- LaptopPro – Chuột không dây Logitech
(5, 19, 1200000, 80),   -- LaptopPro – Bàn phím cơ RGB
(5, 20, 4500000, 60),   -- LaptopPro – Màn hình 27 inch
(1, 21, 28990000, 25),  -- TechViet Store – iPad Pro M4 (admin tạo)
(2, 8, 99000, 200),     -- Fashion Hub – Áo thun basic nam
(2, 9, 450000, 80),     -- Fashion Hub – Quần jean slim fit
(2, 10, 520000, 150),   -- Fashion Hub – Áo sơ mi nam
(2, 11, 600000, 100),   -- Fashion Hub – Áo hoodie unisex
(2, 12, 850000, 90),    -- Fashion Hub – Giày sneaker trắng
(3, 14, 350000, 300),   -- Foods & More – Socola đen 85%
(3, 15, 25000, 500),    -- Foods & More – Snack Poca BBQ
(3, 16, 10000, 1000);   -- Foods & More – Coca Cola 330ml

-- ============================================================
-- 13. CART (1 giỏ hàng / customer)
-- ============================================================
INSERT INTO CART (Cart_ID, Cart_status, Customer_ID) VALUES
(1, 'Active',    11),
(2, 'Active',    12),
(3, 'Saved',     13),
(4, 'Active',    14),
(5, 'Active',    15);

-- ============================================================
-- 14. CART_ITEM 
-- ============================================================
INSERT INTO CART_ITEM (Cart_ID, Store_ID, SProduct_ID, Product_ID, CartItem_quantity) VALUES
-- Cart 1 (Customer 11 - Active)
(1, 1, 3, 2, 1),    -- Samsung S24 (TechViet)
(1, 4, 6, 6, 1),    -- Cáp sạc
-- Cart 2 (Customer 12 - Active)
(2, 1, 1, 1, 1),    -- iPhone (TechViet)
(2, 4, 7, 7, 1),    -- Ốp lưng iPhone
-- Cart 3 (Customer 13 - Saved)
(3, 3, 17, 14, 2),  -- Socola
(3, 3, 18, 15, 3),  -- Snack
-- Cart 4 (Customer 14 - Active)
(4, 5, 8, 18, 1),   -- Chuột Logitech
(4, 5, 9, 19, 1),   -- Bàn phím cơ
-- Cart 5 (Customer 15 - CheckedOut)
(5, 2, 12, 8, 2),   -- Áo thun
(5, 2, 16, 12, 1);  -- Giày sneaker

-- ============================================================
-- 15. ADDRESS
-- ============================================================
INSERT INTO ADDRESS (Address_ID, Customer_ID, Recipient_name, Recipient_phone, Address_type, Details) VALUES
(1, 11, N'Cao Thị Na',     '0911223344', 'Home',   N'12 Nguyễn Oanh, P17, Q Gò Vấp, TP.HCM'),
(2, 11, N'Cao Thị Na',     '0911223344', 'Office', N'Sunwah Tower, 115 Nguyễn Huệ, Q1, TP.HCM'),
(3, 12, N'Lý Văn Oanh',   '0922334455', 'Home',   N'45 Đinh Tiên Hoàng, P3, Q Bình Thạnh, TP.HCM'),
(4, 13, N'Tô Thị Phương', '0933445566', 'Home',   N'78 Võ Thị Sáu, P7, Q3, TP.HCM'),
(5, 13, N'Tô Thị Phương', '0933445566', 'Office', N'Lầu 5, 24 Phan Đăng Lưu, Q Bình Thạnh, TP.HCM'),
(6, 14, N'Hà Minh Quân',  '0944556677', 'Home',   N'99 Lý Thường Kiệt, P8, Q Tân Bình, TP.HCM'),
(7, 15, N'Mã Thị Rồng',   '0955667788', 'Home',   N'52 Nguyễn Văn Lượng, P16, Q Gò Vấp, TP.HCM'),
(8, 15, N'Mã Thị Rồng',   '0955667788', 'Office', N'10 Công Trường Mê Linh, Q1, TP.HCM');

-- ============================================================
-- 16. ORDER
-- ============================================================
INSERT INTO `ORDER` (Customer_ID, Address_ID, Order_status, Order_date, Expected_date, Actual_date) VALUES
(11, 1, 'Completed', '2025-03-01', '2025-03-04', '2025-03-03 15:30:00'),
(12, 3, 'Completed', '2025-03-05', '2025-03-08', '2025-03-07 10:00:00'),
(13, 4, 'Pending',   '2025-03-10', '2025-03-13', NULL),
(11, 1, 'Completed', '2025-04-01', '2025-04-04', '2025-04-03 10:00:00'),
(13, 4, 'Completed', '2025-04-05', '2025-04-09', '2025-04-08 10:30:00'),
(12, 3, 'Cancelled', '2025-04-08', NULL,          NULL),
(14, 6, 'Completed', '2025-04-09', '2025-04-12', '2025-04-11 11:00:00'),
(15, 7, 'Pending',   '2025-04-10', '2025-04-14', NULL),
(11, 1, 'Completed', '2025-07-10', '2025-07-13', '2025-07-12 10:30:00'),
(12, 3, 'Completed', '2025-07-20', '2025-07-23', '2025-07-22 14:00:00'),
(13, 4, 'Completed', '2025-08-05', '2025-08-08', '2025-08-07 09:15:00'),
(12, 3, 'Completed', '2025-10-20', '2025-10-23', '2025-10-22 14:30:00'),
(13, 4, 'Completed', '2025-11-01', '2025-11-04', '2025-11-03 09:00:00'),
(14, 6, 'Completed', '2025-11-15', '2025-11-18', '2025-11-17 16:15:00'),
(15, 7, 'Completed', '2026-01-20', '2026-01-23', '2026-01-22 14:00:00');


-- ============================================================
-- 17. ORDER_ITEM 
-- ============================================================
INSERT INTO ORDER_ITEM (Item_ID, Order_ID, SProduct_ID, Store_ID, Product_ID, Quantity, Price_of_purchase) VALUES
-- Đơn 1: Mua iPhone + Ốp lưng + Cáp tại MobileZone (Store 4)
(1, 1, 2, 4, 1, 1, 33500000),  -- iPhone 15 Pro Max
(2, 1, 7, 4, 7, 1, 120000),    -- Ốp lưng iPhone
(3, 1, 6, 4, 6, 1, 150000),    -- Cáp sạc Type-C
-- Đơn 2: Mua Samsung + Cáp tại TechViet + MobileZone
(1, 2, 3, 1, 2, 1, 22990000),  -- Samsung Galaxy S24 (TechViet)
(2, 2, 6, 4, 6, 1, 150000),    -- Cáp sạc (MobileZone)
-- Đơn 3: Mua bộ PC (Màn hình + Bàn phím + Chuột) tại LaptopPro (Store 5)
(1, 3, 10, 5, 20, 1, 4500000), -- Màn hình 27 inch
(2, 3, 9, 5, 19, 1, 1200000),  -- Bàn phím cơ
(3, 3, 8, 5, 18, 1, 850000),   -- Chuột Logitech
-- Đơn 4: Mua combo thời trang tại Fashion Hub (Store 2)
(1, 4, 12, 2, 8, 2, 99000),    -- Áo thun
(2, 4, 13, 2, 9, 1, 450000),   -- Quần jean
(3, 4, 14, 2, 10, 1, 520000),  -- Áo sơ mi
-- Đơn 5: Mua đồ ăn vặt tại Foods & More (Store 3)
(1, 5, 17, 3, 14, 2, 350000),  -- Socola
(2, 5, 18, 3, 15, 3, 25000),   -- Snack
(3, 5, 19, 3, 16, 5, 10000),   -- Coca Cola
-- Đơn 6: Mua iPhone + phụ kiện tại MobileZone (Store 4)
(1, 6, 2, 4, 1, 1, 33500000),  -- iPhone
(2, 6, 6, 4, 6, 1, 150000),    -- Cáp
(3, 6, 7, 4, 7, 1, 120000),    -- Ốp lưng
-- Đơn 7: Mua đồ uống và ăn vặt tại Foods & More (Store 3)
(1, 7, 18, 3, 15, 2, 25000),   -- Snack
(2, 7, 19, 3, 16, 3, 10000),   -- Coca
-- Đơn 8: Mua thiết bị máy tính tại LaptopPro (Store 5)
(1, 8, 8, 5, 18, 1, 850000),   -- Chuột
(2, 8, 9, 5, 19, 1, 1200000),  -- Bàn phím
-- Đơn 9: Mua thời trang tại Fashion Hub (Store 2)
(1, 9, 12, 2, 8, 1, 99000),    -- Áo thun
(2, 9, 14, 2, 10, 1, 520000),  -- Áo sơ mi
-- Đơn 10: Mua iPad + Cáp tại TechViet + MobileZone
(1, 10, 11, 1, 21, 1, 28990000), -- iPad Pro M4
(2, 10, 6, 4, 6, 1, 150000),     -- Cáp sạc
-- Đơn 11: Mua iPhone + Cáp tại TechViet + MobileZone
(1, 11, 1, 1, 1, 1, 32990000),  -- iPhone (TechViet)
(2, 11, 6, 4, 6, 1, 150000),    -- Cáp (MobileZone)
-- Đơn 12: Mua Samsung + Ốp lưng + Cáp tại MobileZone (Store 4)
(1, 12, 4, 4, 2, 1, 23100000),  -- Samsung
(2, 12, 7, 4, 7, 1, 120000),    -- Ốp lưng
(3, 12, 6, 4, 6, 1, 150000),    -- Cáp
-- Đơn 13: Mua combo LaptopPro tại Store 5
(1, 13, 8, 5, 18, 1, 850000),   -- Chuột
(2, 13, 9, 5, 19, 1, 1200000),  -- Bàn phím
(3, 13, 10, 5, 20, 1, 4500000), -- Màn hình
-- Đơn 14: Mua đồ ăn tại Foods & More (Store 3)
(1, 14, 17, 3, 14, 1, 350000),  -- Socola
(2, 14, 18, 3, 15, 2, 25000),   -- Snack
-- Đơn 15: Mua thời trang tại Fashion Hub (Store 2)
(1, 15, 12, 2, 8, 1, 99000),    -- Áo thun
(2, 15, 13, 2, 9, 1, 450000),   -- Quần jean
(3, 15, 16, 2, 12, 1, 850000);  -- Giày sneaker

-- ============================================================
-- 18. PAYMENT
-- ============================================================
INSERT INTO PAYMENT (Payment_ID, Order_ID, Method, Payment_date, Payment_status, Amount) VALUES
(1,  1,  'Card',     '2025-03-01', 'Paid',      33770000), 
(2,  2,  'E-Wallet', '2025-03-05', 'Paid',      23140000), 
(3,  3,  'Cash',     '2025-03-10', 'Pending',    6550000), -- Pending
(4,  4,  'Card',     '2025-04-01', 'Paid',       1158000), -- giảm 10,000 (dùng loyalty point)
(5,  5,  'E-Wallet', '2025-04-05', 'Paid',        865000), 
(6,  6,  'Card',     '2025-04-08', 'Cancelled',  33770000), -- Cancelled
(7,  7,  'E-Wallet', '2025-04-09', 'Paid',         80000), 
(8,  8,  'Cash',     '2025-04-10', 'Pending',    2050000), -- Pending
(9,  9,  'E-Wallet', '2025-07-10', 'Paid',        619000), 
(10, 10, 'Card',     '2025-07-20', 'Paid',      29140000), 
(11, 11, 'E-Wallet', '2025-08-05', 'Paid',      33140000), 
(12, 12, 'Card',     '2025-10-20', 'Paid',      23470000), 
(13, 13, 'Cash',     '2025-11-01', 'Paid',       6550000), 
(14, 14, 'Card',     '2025-11-15', 'Paid',        400000), 
(15, 15, 'E-Wallet', '2026-01-20', 'Paid',       1390000); 

-- ============================================================
-- 19. LOYALTY_POINTS (PK: Transaction_ID + Order_ID)
-- ============================================================
INSERT INTO LOYALTY_POINTS (Transaction_ID, Order_ID, Customer_ID, `Transaction`, Expiry_date) VALUES
-- Customer 11 
(1, 1, 11, 337700, '2026-03-01 00:00:00'),  -- Order 1 (earn)
(2, 4, 11, 11680,  '2026-04-01 00:00:00'),  -- Order 4 (earn)
(3, 4, 11, -10000, '2026-04-01 00:00:00'),  -- Order 4 (use point từ Order 1)
(4, 9, 11, 6190,   '2026-07-10 00:00:00'),  -- Order 9
-- Customer 12 
(5, 2, 12, 231400, '2026-03-05 00:00:00'),  
(6, 10,12, 291400,    '2026-07-20 00:00:00'),
(7, 12,12, 233700, '2026-10-20 00:00:00'),
-- Customer 13 
(8, 5, 13, 159900, '2026-04-05 00:00:00'),
(9, 11,13, 331400, '2026-08-05 00:00:00'),
(10,13,13, 65500,   '2026-11-01 00:00:00'),
-- Customer 14 
(11,7, 14, 5200,   '2026-04-09 00:00:00'),
(12,14,14, 229900, '2026-11-15 00:00:00'),
-- Customer 15
(13,15,15, 8400,   '2027-01-20 00:00:00');

-- ============================================================
-- 20. APPLIED_TO (điểm được áp dụng vào đơn hàng)
-- ============================================================
INSERT INTO APPLIED_TO (Order_ID, Transaction_ID) VALUES
(4, 3);  -- Đơn 4 dùng điểm từ Customer 11 (đã tích điểm từ đơn 1)

-- ============================================================
-- 21. SHIPMENT
-- ============================================================
INSERT INTO SHIPMENT (Shipment_ID, Driver_ID, Order_ID, Status) VALUES
(1, 16, 1,  'Delivered'),
(2, 17, 2,  'Delivered'),
(3, 18, 3,  'Shipping'),
(4, 19, 4,  'Delivered'),
(5, 20, 5,  'Delivered'),
(6, 17, 7,  'Delivered'),
(7, 16, 8,  'Pending'),
(8, 20, 9,  'Delivered'),
(9, 16, 10, 'Delivered'),
(10, 17, 11, 'Delivered'),
(11, 18, 12, 'Delivered'),
(12, 19, 13, 'Delivered'),
(13, 20, 14, 'Delivered'),
(14, 16, 15, 'Delivered');

-- ============================================================
-- 22. TRACKING_HISTORY
-- ============================================================
INSERT INTO TRACKING_HISTORY (Tracking_ID, Shipment_ID, Current_location, Status_updated, Time_stamp) VALUES
-- Shipment 1 (Order 1 - Delivered)
(1, 1, N'Kho MobileZone - Q10, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-03-01 12:00:00'),
(2, 1, N'12 Nguyễn Oanh, Gò Vấp, TP.HCM', N'Đã giao hàng thành công', '2025-03-03 15:30:00'),
-- Shipment 2 (Order 2 - Delivered)
(1, 2, N'Kho TechViet - Q1, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-03-05 16:00:00'),
(2, 2, N'45 Đinh Tiên Hoàng, Bình Thạnh, TP.HCM', N'Đã giao hàng thành công', '2025-03-07 10:00:00'),
-- Shipment 3 (Order 3 - Shipping)
(1, 3, N'Kho LaptopPro - Thủ Đức, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-03-10 12:00:00'),
(2, 3, N'Trung tâm phân phối Q9, TP.HCM', N'Đang vận chuyển', '2025-03-11 09:00:00'),
-- Shipment 4 (Order 4 - Delivered)
(1, 4, N'Kho Fashion Hub - Q1, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-04-01 10:00:00'),
(2, 4, N'12 Nguyễn Oanh, Gò Vấp, TP.HCM', N'Đã giao hàng thành công', '2025-04-03 10:00:00'),
-- Shipment 5 (Order 5 - Delivered)
(1, 5, N'Kho Foods & More - Q5, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-04-05 12:00:00'),
(2, 5, N'78 Võ Thị Sáu, Q3, TP.HCM', N'Đã giao hàng thành công', '2025-04-08 10:30:00'),
-- Shipment 6 (Order 7 - Delivered)
(1, 6, N'Kho Fashion Hub - Q1, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-04-09 10:00:00'),
(2, 6, N'99 Lý Thường Kiệt, Tân Bình, TP.HCM', N'Đã giao hàng thành công', '2025-04-11 11:00:00'),
-- Shipment 7 (Order 8 - Pending)
(1, 7, N'Kho Foods & More - Q5, TP.HCM', N'Đơn hàng đang được chuẩn bị', '2025-04-10 09:00:00'),
-- Shipment 8 (Order 9 - Delivered)
(1, 8, N'Kho Fashion Hub - Q1, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-07-10 11:00:00'),
(2, 8, N'12 Nguyễn Oanh, Gò Vấp, TP.HCM', N'Đã giao hàng thành công', '2025-07-12 10:30:00'),
-- Shipment 9 (Order 10 - Delivered)
(1, 9, N'Kho TechViet - Q1, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-07-20 12:00:00'),
(2, 9, N'45 Đinh Tiên Hoàng, Bình Thạnh, TP.HCM', N'Đã giao hàng thành công', '2025-07-22 14:00:00'),
-- Shipment 10 (Order 11 - Delivered)
(1, 10, N'Kho TechViet - Q1, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-08-05 11:00:00'),
(2, 10, N'78 Võ Thị Sáu, Q3, TP.HCM', N'Đã giao hàng thành công', '2025-08-07 09:15:00'),
-- Shipment 11 (Order 12 - Delivered)
(1, 11, N'Kho MobileZone - Q10, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-10-20 11:00:00'),
(2, 11, N'45 Đinh Tiên Hoàng, Bình Thạnh, TP.HCM', N'Đã giao hàng thành công', '2025-10-22 14:30:00'),
-- Shipment 12 (Order 13 - Delivered)
(1, 12, N'Kho LaptopPro - Thủ Đức, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-11-01 10:00:00'),
(2, 12, N'78 Võ Thị Sáu, Q3, TP.HCM', N'Đã giao hàng thành công', '2025-11-03 09:00:00'),
-- Shipment 13 (Order 14 - Delivered)
(1, 13, N'Kho Foods & More - Q5, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2025-11-15 12:00:00'),
(2, 13, N'99 Lý Thường Kiệt, Tân Bình, TP.HCM', N'Đã giao hàng thành công', '2025-11-17 16:15:00'),
-- Shipment 14 (Order 15 - Delivered)
(1, 14, N'Kho Fashion Hub - Q1, TP.HCM', N'Đã lấy hàng từ cửa hàng', '2026-01-20 11:00:00'),
(2, 14, N'52 Nguyễn Văn Lượng, Gò Vấp, TP.HCM', N'Đã giao hàng thành công', '2026-01-22 14:00:00');

-- ============================================================
-- 23. REVIEW (chỉ cho đơn Completed)
-- ============================================================
INSERT INTO REVIEW (Order_ID, Item_ID, Customer_ID, Rating, `Comment`, Review_date) VALUES
-- Order 1 (iPhone + Ốp + Cáp)
(1, 1, 11, 5, N'iPhone 15 Pro Max dùng rất mượt, camera đẹp.', '2025-03-04'),
(1, 2, 11, 4, N'Ốp lưng chắc chắn, ôm máy tốt.', '2025-03-04'),
(1, 3, 11, 5, N'Cáp sạc nhanh, dùng ổn định.', '2025-03-04'),
-- Order 2 (Samsung + Cáp)
(2, 1, 12, 4, N'Samsung S24 Ultra màn hình đẹp, pin tốt.', '2025-03-08'),
(2, 2, 12, 5, N'Cáp sạc chất lượng, sạc nhanh.', '2025-03-08'),
-- Order 4 (Áo thun + Quần + Sơ mi)
(4, 1, 11, 5, N'Áo thun mềm, mặc thoải mái.', '2025-04-05'),
(4, 2, 11, 4, N'Quần jean form đẹp, co giãn tốt.', '2025-04-05'),
(4, 3, 11, 5, N'Áo sơ mi vải mát, mặc đi làm hợp.', '2025-04-05'),
-- Order 5 (Socola + Snack + Coca)
(5, 1, 13, 5, N'Socola Godiva ngon, vị đậm.', '2025-04-09'),
(5, 2, 13, 4, N'Snack giòn, ăn vui miệng.', '2025-04-09'),
(5, 3, 13, 5, N'Coca Cola mát lạnh, đúng vị.', '2025-04-09'),
-- Order 7 (Snack + Coca)
(7, 1, 14, 4, N'Snack ăn ổn, đóng gói tốt.', '2025-04-12'),
(7, 2, 14, 5, N'Coca uống ngon, giao nhanh.', '2025-04-12'),
-- Order 9 (Áo thun + Áo sơ mi)
(9, 1, 11, 5, N'Áo thun mặc dễ chịu.', '2025-07-13'),
(9, 2, 11, 5, N'Áo sơ mi đẹp, form chuẩn.', '2025-07-13'),
-- Order 11 (iPhone + Cáp)
(11, 1, 13, 5, N'iPhone hiệu năng mạnh, pin ổn.', '2025-08-08'),
(11, 2, 13, 5, N'Cáp sạc nhanh, bền.', '2025-08-08'),
-- Order 12 (Samsung + Ốp + Cáp)
(12, 1, 12, 5, N'Samsung S24 Ultra chụp ảnh đẹp.', '2025-10-23'),
(12, 2, 12, 4, N'Ốp lưng chắc chắn.', '2025-10-23'),
(12, 3, 12, 5, N'Cáp sạc dùng tốt.', '2025-10-23'),
-- Order 13 (Chuột + Bàn phím + Màn hình)
(13, 1, 13, 4, N'Chuột Logitech dùng tốt, pin lâu.', '2025-11-05'),
(13, 2, 13, 5, N'Bàn phím cơ gõ rất thích, đèn đẹp.', '2025-11-05'),
(13, 3, 13, 5, N'Màn hình LG màu sắc chuẩn, rất hài lòng.', '2025-11-05'),
-- Order 14 (Socola + Snack)
(14, 1, 14, 5, N'Socola ngon, đáng tiền.', '2025-11-18'),
(14, 2, 14, 4, N'Snack ăn khá ổn.', '2025-11-18'),
-- Order 15 (Áo thun + Quần + Giày)
(15, 1, 15, 5, N'Áo thun mặc thoải mái.', '2026-01-23'),
(15, 2, 15, 4, N'Quần jean đẹp, vừa vặn.', '2026-01-23'),
(15, 3, 15, 5, N'Giày sneaker đi êm, rất thích.', '2026-01-23');

SET FOREIGN_KEY_CHECKS = 1;

-- Kiểm tra nhanh
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'Omnilogi'
ORDER BY TABLE_NAME;

SELECT 'Dữ liệu mẫu đã được chèn thành công!' AS Ket_qua;