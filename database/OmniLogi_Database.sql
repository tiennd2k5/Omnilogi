DROP DATABASE IF EXISTS Omnilogi;
CREATE DATABASE Omnilogi;
USE Omnilogi;
-- =====================================================
-- 1. USER
-- =====================================================
CREATE TABLE USER (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_Role VARCHAR(50) NOT NULL,
    User_name VARCHAR(50) NOT NULL 	,
    `Password` VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    First_name NVARCHAR(50) NOT NULL,
    Middle_name NVARCHAR(50),
    Last_name NVARCHAR(50),
    Gender VARCHAR(10),
    Date_of_birth DATE,
    User_status NVARCHAR(20),  
    Created_date DATETIME,
    Admin_ID INT NULL,
    CHECK (Gender IN ('Male', 'Female', 'Other')),
    CHECK(User_status IN('Active', 'Inactived', 'Banned', 'Unverify'))
);

-- =====================================================
-- 2. USER_PHONE
-- =====================================================
CREATE TABLE USER_PHONE(
	User_ID INT NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    PRIMARY KEY (USER_ID, Phone),
    FOREIGN KEY (User_ID) REFERENCES USER(User_ID)
    ON DELETE CASCADE
);
-- =====================================================
-- 3. ADMIN
-- =====================================================
CREATE TABLE ADMIN (
    User_ID INT KEY,
    Admin_level INT NOT NULL,
    Last_login DATETIME,
    CHECK (Admin_level >= 1),
    FOREIGN KEY (User_ID) REFERENCES USER(User_ID)
);

-- =====================================================
-- RÀNG BUỘC KHÓA NGOẠI USER SAU KHI CÓ BẢNG ADMIN
-- =====================================================
ALTER TABLE `USER`
ADD FOREIGN KEY (Admin_ID) REFERENCES ADMIN(USER_ID);

-- =====================================================
-- 4. STORE_MANAGER
-- =====================================================
CREATE TABLE STORE_MANAGER (
    User_ID INT PRIMARY KEY,
    Tax_code VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (User_ID) REFERENCES USER(User_ID)
);

-- =====================================================
-- 5. CUSTOMER
-- =====================================================
CREATE TABLE CUSTOMER (
    User_ID INT PRIMARY KEY,
    FOREIGN KEY (User_ID) REFERENCES USER(User_ID)
);

-- =====================================================
-- 6. DRIVER
-- =====================================================
CREATE TABLE DRIVER (
    User_ID INT PRIMARY KEY,
    License_num VARCHAR(20),
    Vehicle_type VARCHAR(50),
    Driver_status VARCHAR(20),
    Total_deliveries INT DEFAULT 0,
    CHECK (Driver_status IN ('Available', 'Busy', 'Offline')),
    FOREIGN KEY (User_ID) REFERENCES USER(User_ID)
);

-- =====================================================
-- 7. VEHICLE
-- =====================================================
CREATE TABLE VEHICLE (
    Vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    Plate_number VARCHAR(20),
    `Type` VARCHAR(50),
    `Status` VARCHAR(20),
    CHECK (Status IN ('Available', 'In use', 'Maintenance'))
);

-- =====================================================
-- 8. USE
-- =====================================================
CREATE TABLE `USE`(
    User_ID INT NOT NULL,
    Vehicle_id INT NOT NULL,
    PRIMARY KEY (User_ID, Vehicle_id),
    FOREIGN KEY (User_ID) REFERENCES DRIVER(User_ID),
    FOREIGN KEY (Vehicle_id) REFERENCES VEHICLE(Vehicle_id)
);

-- =====================================================
-- 9. CATEGORY (đệ quy)
-- =====================================================
CREATE TABLE CATEGORY (
    Category_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category_name VARCHAR(100) NOT NULL,
    Admin_ID INT NOT NULL,
    FOREIGN KEY (Admin_ID) REFERENCES ADMIN(USER_ID)
);

-- =====================================================
-- 9.1. SUB_CATEGORY (đệ quy)
-- =====================================================
CREATE TABLE SUB_CATEGORY (
    Category_ID INT NOT NULL,
    Sub_category_ID INT AUTO_INCREMENT NOT NULL, 
    Sub_category_Name NVARCHAR(100) NOT NULL, 
    PRIMARY KEY (Sub_category_ID, Category_ID),
    FOREIGN KEY (Category_ID) REFERENCES CATEGORY(Category_ID) ON DELETE CASCADE
);
-- =====================================================
-- 10. STORE
-- =====================================================
CREATE TABLE STORE (
    Store_ID INT AUTO_INCREMENT PRIMARY KEY,
    Admin_ID INT NOT NULL,
    Manager_ID INT NOT NULL,
    `Name` NVARCHAR(100),
    `Description` NVARCHAR(255),
    Store_address NVARCHAR(255),
    FOREIGN KEY (Admin_ID) REFERENCES ADMIN(USER_ID),
    FOREIGN KEY (Manager_ID) REFERENCES STORE_MANAGER(USER_ID)
);

-- =====================================================
-- 10.1. STORE_Categorical
-- =====================================================
CREATE TABLE STORE_Categorical(
	Store_ID INT NOT NULL,
    Categorical NVARCHAR(255) NOT NULL,
    PRIMARY KEY (Store_ID, Categorical),
    FOREIGN KEY (Store_ID) REFERENCES STORE(Store_ID)
);

-- =====================================================
-- 11. PRODUCT
-- =====================================================
CREATE TABLE PRODUCT (
    Product_ID INT AUTO_INCREMENT PRIMARY KEY,
    Category_ID INT NOT NULL,
    `Name` VARCHAR(100) NOT NULL,
    `Description` TEXT,
    Brand VARCHAR(50),
    image_url VARCHAR(255),
    status VARCHAR(50) DEFAULT 'Pending', 
    Created_by_ID INT, -- Cho phép NULL để Admin có thể tự tạo sản phẩm mà không cần Store Manager

    CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    FOREIGN KEY (Category_ID) REFERENCES CATEGORY(Category_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (Created_by_ID) REFERENCES STORE_MANAGER(User_ID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- =====================================================
-- 12. STORE_PRODUCT
-- =====================================================
CREATE TABLE STORE_PRODUCT (
    SProduct_ID INT AUTO_INCREMENT PRIMARY KEY,
    Store_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    UNIQUE(Store_ID, Product_ID),
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Stock_quantity INT NOT NULL DEFAULT 0 CHECK (Stock_quantity >= 0),
    FOREIGN KEY (Store_ID) REFERENCES STORE(Store_ID) ON DELETE CASCADE,
    FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID) ON DELETE CASCADE
);


-- =====================================================
-- 14. CART
-- =====================================================
CREATE TABLE CART (
    Cart_ID INT AUTO_INCREMENT PRIMARY KEY,
    Cart_status VARCHAR(20),
    Customer_ID INT UNIQUE NOT NULL,
    CHECK (Cart_status IN ('Active', 'CheckedOut', 'Abandoned', 'Saved')),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(User_ID) ON DELETE CASCADE
);

-- =====================================================
-- 15. CART_ITEM
-- =====================================================
CREATE TABLE CART_ITEM (
    CartItem_ID INT AUTO_INCREMENT PRIMARY KEY,
    Cart_ID INT NOT NULL,
    Store_ID INT NOT NULL,
    SProduct_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    UNIQUE(Cart_ID, Store_ID, SProduct_ID, Product_ID),  
    CartItem_quantity INT CHECK (CartItem_quantity > 0),
		
    FOREIGN KEY (Cart_ID) REFERENCES CART(Cart_ID),
    FOREIGN KEY (Store_ID) REFERENCES STORE(Store_ID),
    FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID),
    FOREIGN KEY (SProduct_ID) REFERENCES STORE_PRODUCT(SProduct_ID)
);

-- =====================================================
-- 16. ADDRESS
-- =====================================================
CREATE TABLE ADDRESS (
    Address_ID INT AUTO_INCREMENT NOT NULL,
    Customer_ID INT NOT NULL,
    PRIMARY KEY(Address_ID, Customer_ID),
    Recipient_name VARCHAR(100),
    Recipient_phone VARCHAR(10),
    Address_type VARCHAR(50),
    Details VARCHAR(255),
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(User_ID) ON DELETE CASCADE
);

-- =====================================================
-- 17. ORDER
-- =====================================================
CREATE TABLE `ORDER` (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Address_ID INT NOT NULL,
    Order_status VARCHAR(20),
    Order_date DATE,
    Expected_date DATE,
    Actual_date DATETIME,
    CHECK (Order_status IN ('Pending', 'Completed','Cancelled')),	
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(User_ID),
    FOREIGN KEY (Address_ID, Customer_ID) REFERENCES ADDRESS(Address_ID, Customer_ID)  
);

-- =====================================================
-- 18. ORDER_ITEM
-- =====================================================
CREATE TABLE ORDER_ITEM (
    Item_ID INT AUTO_INCREMENT NOT NULL,
    Order_ID INT NOT NULL,
    PRIMARY KEY(Item_ID, Order_ID),
    SProduct_ID INT NOT NULL,
    Store_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    Price_of_purchase DECIMAL(10,2),
    FOREIGN KEY (Order_ID) REFERENCES `ORDER`(Order_ID),
    FOREIGN KEY (SProduct_ID) REFERENCES STORE_PRODUCT(SProduct_ID),
    FOREIGN KEY (Store_ID) REFERENCES STORE(Store_ID),
    FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID)
);

-- =====================================================
-- 19. PAYMENT
-- =====================================================
CREATE TABLE PAYMENT (
    Payment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT UNIQUE NOT NULL,
    Method VARCHAR(50),
    Payment_date DATE,
    Payment_status VARCHAR(20),
    Amount DECIMAL(15,2) CHECK (Amount >= 0),
    CHECK (Method IN ('Cash', 'Card', 'E-Wallet')),
    CHECK (Payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded', 'Cancelled')),
    FOREIGN KEY (Order_ID) REFERENCES `ORDER`(Order_ID)
);

-- =====================================================
-- 20. LOYALTY_POINTS
-- =====================================================
CREATE TABLE LOYALTY_POINTS (
    Transaction_ID INT AUTO_INCREMENT NOT NULL,
    Order_ID INT NOT NULL, 
    PRIMARY KEY(Transaction_ID, Order_ID),
    Customer_ID INT NOT NULL,
    `Transaction` INT ,
    Expiry_date DATETIME,
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(USER_ID),
    FOREIGN KEY (Order_ID) REFERENCES `ORDER`(Order_ID)
);

-- =====================================================
-- 20.1. APPLIED_TO
-- =====================================================
CREATE TABLE APPLIED_TO(
	Order_ID INT PRIMARY KEY,
    Transaction_ID INT NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES `ORDER`(Order_ID),
    FOREIGN KEY (Transaction_ID) REFERENCES LOYALTY_POINTS(Transaction_ID)
);

-- =====================================================
-- 21. SHIPMENT
-- =====================================================
CREATE TABLE SHIPMENT (
    Shipment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Driver_ID INT NOT NULL,
    Order_ID INT NOT NULL,
    Status VARCHAR(20) NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES `ORDER`(Order_ID),
    FOREIGN KEY (Driver_ID) REFERENCES DRIVER(USER_ID),
    CHECK (Status IN ('Pending','Shipping','Delivered'))
);

-- =====================================================
-- 22. TRACKING_HISTORY
-- =====================================================
CREATE TABLE TRACKING_HISTORY (
    Tracking_ID INT AUTO_INCREMENT NOT NULL,
    Shipment_ID INT NOT NULL,
    PRIMARY KEY (Tracking_ID, Shipment_ID),
    Current_location VARCHAR(255),
    Status_updated VARCHAR(255),
    Time_stamp TIMESTAMP,
    FOREIGN KEY (Shipment_ID) REFERENCES SHIPMENT(Shipment_ID)
);

-- =====================================================
-- 23. REVIEW
-- =====================================================
CREATE TABLE REVIEW (
    Review_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    UNIQUE(Order_ID, Item_ID),
    Customer_ID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    `Comment` VARCHAR(255),
    Image VARCHAR(255),
    Review_date DATE,
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(User_ID),
    FOREIGN KEY (Item_ID, Order_ID) REFERENCES ORDER_ITEM(Item_ID, Order_ID)
);

