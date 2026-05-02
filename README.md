# OmniLogi

OmniLogi là project mô phỏng hệ thống thương mại điện tử tích hợp logistics. Repo hiện gồm backend Express API, frontend React/Vite và các file SQL cho MySQL.

## Công nghệ sử dụng

- Backend: Node.js, Express.js, mysql2/promise, dotenv, cors
- Frontend: React, React Router, Axios, Vite, ESLint
- Database: MySQL 8
- Công cụ chạy database: Docker Compose

## Cấu trúc project

```text
Omnilogi/
|-- backend/
|   |-- app.js
|   |-- server.js
|   |-- package.json
|   |-- config/
|   |-- controllers/
|   |-- middleware/
|   |-- routes/
|   |-- services/
|   `-- utils/
|
|-- frontend/
|   |-- index.html
|   |-- package.json
|   |-- vite.config.js
|   |-- public/
|   `-- src/
|       |-- api/
|       |-- assets/
|       |-- pages/
|       |-- App.jsx
|       `-- main.jsx
|
|-- database/
|   |-- OmniLogi_Database.sql
|   |-- data_btl2.sql
|   |-- procedure - product.sql
|   |-- crud - product.sql
|   |-- funct.sql
|   `-- trigger.sql
|
|-- docker-compose.yml
`-- README.md
```

## Cài đặt

### 1. Clone project

```bash
git clone https://github.com/tiennd2k5/Omnilogi.git
cd Omnilogi
```

### 2. Cài dependencies backend

```bash
cd backend
npm install
```

Backend dùng file `backend/.env` với cấu hình mặc định:

```text
PORT=8080
DB_HOST=localhost
DB_PORT=3307
DB_USER=root
DB_PASSWORD=123456
DB_NAME=Omnilogi
```

### 3. Cài dependencies frontend

```bash
cd ../frontend
npm install
```

Frontend đang gọi API tại:

```text
http://localhost:8080/api
```

## Chạy project

### 1. Chạy MySQL bằng Docker

Từ thư mục gốc project:

```bash
docker compose up -d
```

Thông tin kết nối MySQL:

```text
Host: localhost
Port: 3307
User: root
Password: 123456
Database: Omnilogi
```

Import các file SQL trong thư mục `database/`, gồm schema, data, procedure/function và trigger.

### 2. Chạy backend

```bash
cd backend
npm run dev
```

Backend mặc định chạy tại:

```text
http://localhost:8080
```

### 3. Chạy frontend

Mở terminal khác:

```bash
cd frontend
npm run dev
```

Frontend Vite mặc định chạy tại:

```text
http://localhost:5173
```

## Frontend

Các màn hình chính:

- `/`: danh sách sản phẩm, lọc theo danh mục/trạng thái, tìm kiếm, xem chi tiết và xem gợi ý mua kèm.
- `/products`: quản lý sản phẩm, thêm/sửa/xóa sản phẩm, lọc và tìm kiếm.
- `/tier`: tra cứu hạng thành viên của khách hàng theo ID hoặc username mẫu.
- `/revenue`: thống kê doanh thu cửa hàng theo store, khoảng ngày và doanh thu tối thiểu.

## API Endpoints

### Product

```http
GET    /api/products
GET    /api/products?status=Approved
GET    /api/products?category_id=1
GET    /api/products?search=phone
GET    /api/products/:id
GET    /api/products/:id/recommendations
GET    /api/products/:id/recommendations?min_confidence=40
POST   /api/products
PUT    /api/products/:id
DELETE /api/products/:id
```

Ví dụ tạo sản phẩm:

```json
{
  "category_id": 1,
  "name": "Laptop ABC",
  "desc": "Laptop văn phòng",
  "brand": "ABC",
  "image_url": "https://example.com/image.jpg",
  "status": "Pending",
  "created_by_id": 11
}
```

### Store

```http
GET /api/stores/revenue-stats
GET /api/stores/revenue-stats?store_id=1
GET /api/stores/revenue-stats?from_date=2026-01-01&to_date=2026-12-31
GET /api/stores/revenue-stats?min_revenue=10000000
```

### Customer

```http
GET /api/customers/:id/tier
```

### Shipment

Status hợp lệ:

```text
Pending, Shipping, Delivered
```

```http
GET    /api/shipments/statuses
GET    /api/shipments
GET    /api/shipments?status=Pending
GET    /api/shipments?driver_id=16
GET    /api/shipments?order_id=1
GET    /api/shipments/:id
POST   /api/shipments
PUT    /api/shipments/:id
DELETE /api/shipments/:id
```

Ví dụ tạo shipment:

```json
{
  "driver_id": 16,
  "order_id": 1,
  "status": "Pending"
}
```

### Driver

```http
GET /api/drivers
GET /api/drivers/:id
GET /api/drivers/:id/delivery-stats
```

### Review

```http
GET    /api/reviews
GET    /api/reviews?customer_id=12
GET    /api/reviews?order_id=1
GET    /api/reviews?item_id=1
GET    /api/reviews/reviewable-items
GET    /api/reviews/reviewable-items?customer_id=12
GET    /api/reviews/:id
POST   /api/reviews
DELETE /api/reviews/:id
```

Ví dụ tạo review:

```json
{
  "order_id": 1,
  "item_id": 1,
  "customer_id": 12,
  "rating": 5,
  "comment": "Sản phẩm tốt",
  "image": null
}
```

## Trigger và function

### Trigger shipment

File `database/trigger.sql` có các trigger cập nhật `DRIVER.Total_deliveries` khi shipment có trạng thái `Delivered`:

- `trg_UpdateDelivery_Insert`
- `trg_UpdateDelivery_Update`
- `trg_UpdateDelivery_Delete`

Cách test nhanh:

```http
GET /api/drivers/16/delivery-stats
POST /api/shipments
GET /api/drivers/16/delivery-stats
```

Payload:

```json
{
  "driver_id": 16,
  "order_id": 11,
  "status": "Delivered"
}
```

### Trigger review

Trigger `trg_Check_Review` chỉ cho tạo review khi:

- `Item_ID` thuộc đúng `Order_ID`.
- `Order_ID` thuộc đúng `Customer_ID`.
- `Order_status = Completed`.

Cách test nhanh:

```http
GET /api/reviews/reviewable-items
POST /api/reviews
```

Nếu dữ liệu không hợp lệ, MySQL trả `SIGNAL SQLSTATE '45000'` và backend trả response lỗi.

## Response Format

Success:

```json
{
  "success": true,
  "data": [],
  "message": "OK"
}
```

Error:

```json
{
  "success": false,
  "message": "Error message"
}
```

## Kiểm tra nhanh

Frontend:

```bash
cd frontend
npm run lint
npm run build
```

Backend:

```bash
cd backend
node --check app.js
node --check server.js
```
