# OmniLogi Backend API

Backend cho he thong **OmniLogi** - san thuong mai dien tu tich hop logistics.

## Cong nghe su dung

- Node.js
- Express.js
- MySQL 8
- mysql2/promise
- dotenv
- cors
- Docker
- DBeaver

## Cau truc backend

```text
backend/
|-- app.js
|-- server.js
|-- package.json
|-- package-lock.json
|-- .env
|
|-- config/
|   `-- database.js
|
|-- controllers/
|   |-- productController.js
|   |-- storeController.js
|   |-- customerController.js
|   |-- shipmentController.js
|   |-- driverController.js
|   `-- reviewController.js
|
|-- services/
|   |-- productServices.js
|   |-- storeServices.js
|   |-- customerServices.js
|   |-- shipmentServices.js
|   |-- driverServices.js
|   `-- reviewServices.js
|
|-- routes/
|   |-- index.js
|   |-- productRoutes.js
|   |-- storeRoutes.js
|   |-- customerRoutes.js
|   |-- shipmentRoutes.js
|   |-- driverRoutes.js
|   `-- reviewRoutes.js
|
|-- middleware/
|   `-- errorHandle.js
|
`-- utils/
    `-- response.js
```

## Setup

1. Clone project:

```bash
git clone https://github.com/tiennd2k5/Omnilogi.git
```

2. Cai Node modules:

```bash
cd backend
npm install
```

3. Cai va mo Docker Desktop.

## Chay project

### 1. Chay MySQL bang Docker

```bash
docker compose up -d
```

Kiem tra container:

```bash
docker ps
```

### 2. Import SQL

Ket noi MySQL:

```text
Host: localhost
Port: 3307
User: root
Password: 123456
Database: Omnilogi
```

Import cac file SQL trong thu muc `database/`, gom schema, data, procedure, function va trigger.

### 3. Chay backend

```bash
cd backend
npm run dev
```

Server mac dinh:

```text
http://localhost:8080
```

## API Endpoints

### Product Module

```http
GET    /api/products
GET    /api/products/:id
GET    /api/products/:id/recommendations
POST   /api/products
PUT    /api/products/:id
DELETE /api/products/:id
```

### Store Module

```http
GET /api/stores/revenue-stats
```

### Customer Module

```http
GET /api/customers/:id/tier
```

### Shipment Module

Status hop le:

```text
Pending, Shipping, Delivered
```

```http
GET    /api/shipments
GET    /api/shipments?status=Pending
GET    /api/shipments?driver_id=16
GET    /api/shipments?order_id=1
GET    /api/shipments/statuses
GET    /api/shipments/:id
POST   /api/shipments
PUT    /api/shipments/:id
DELETE /api/shipments/:id
```

Vi du tao shipment:

```json
{
  "driver_id": 16,
  "order_id": 1,
  "status": "Pending"
}
```

### Driver Module

Dung de xem thong tin tai xe va kiem tra trigger shipment cap nhat `Total_deliveries`.

```http
GET /api/drivers
GET /api/drivers/:id
GET /api/drivers/:id/delivery-stats
```

### Review Module

Dung de tao review va kich hoat trigger `trg_Check_Review`.

```http
GET    /api/reviews
GET    /api/reviews?customer_id=12
GET    /api/reviews?order_id=1
GET    /api/reviews/:id
GET    /api/reviews/reviewable-items
GET    /api/reviews/reviewable-items?customer_id=12
POST   /api/reviews
DELETE /api/reviews/:id
```

Vi du tao review:

```json
{
  "order_id": 1,
  "item_id": 1,
  "customer_id": 12,
  "rating": 5,
  "comment": "San pham tot",
  "image": null
}
```

## API phuc vu trigger

### Trigger shipment

File `database/trigger.sql` co cac trigger:

- `trg_UpdateDelivery_Insert`: chay khi insert vao `SHIPMENT`.
- `trg_UpdateDelivery_Update`: chay khi update `SHIPMENT.Status`.
- `trg_UpdateDelivery_Delete`: chay khi delete shipment da `Delivered`.

Cach test qua API:

1. Xem so lan giao hang cua driver:

```http
GET /api/drivers/16/delivery-stats
```

2. Tao shipment status `Delivered`:

```http
POST /api/shipments
```

```json
{
  "driver_id": 16,
  "order_id": 11,
  "status": "Delivered"
}
```

3. Xem lai:

```http
GET /api/drivers/16/delivery-stats
```

### Trigger review

Trigger `trg_Check_Review` chi cho review neu:

- `Item_ID` thuoc dung `Order_ID`.
- `Order_ID` thuoc dung `Customer_ID`.
- `Order_status = Completed`.

Cach test qua API:

1. Lay danh sach item co the review:

```http
GET /api/reviews/reviewable-items
```

2. Tao review hop le bang mot item trong danh sach tren:

```http
POST /api/reviews
```

3. Tao review sai `item_id/order_id/customer_id` de trigger tra loi:

```json
{
  "order_id": 2,
  "item_id": 9999,
  "customer_id": 16,
  "rating": 5
}
```

Neu trigger bao loi `SIGNAL SQLSTATE '45000'`, backend se tra response loi `400`.

## Response Format

### Success

```json
{
  "success": true,
  "data": [],
  "message": "OK"
}
```

### Error

```json
{
  "success": false,
  "message": "Error message"
}
```
