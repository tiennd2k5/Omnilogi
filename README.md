# OmniLogi Backend API

Backend hệ thống **OmniLogi** – sàn thương mại điện tử tích hợp logistics.

---

# Công nghệ sử dụng

* Node.js
* Express.js
* MySQL 8
* mysql2/promise
* dotenv
* cors
* Docker
* DBeaver

---

# Cấu trúc backend

```text id="zpcd3k"
backend/
│── app.js
│── server.js
│── package.json
│── package-lock.json
│── .env
│
├── config/
│   └── database.js
│
├── controllers/
│   ├── productController.js
│   ├── storeController.js
│   └── customerController.js
│
├── services/
│   ├── productServices.js
│   ├── storeServices.js
│   └── customerServices.js
│
├── routes/
│   ├── index.js
│   ├── productRoutes.js
│   ├── storeRoutes.js
│   └── customerRoutes.js
│
├── middlewares/
│   └── errorHandler.js
│
└── utils/
    └── response.js
```
# Set up
1. Clone project

git clone https://github.com/tiennd2k5/Omnilogi.git

2. Install Node Modules

npm install

3. Cài docker desktop
---

# Chạy project

## 1. Chạy MySQL bằng Docker

```bash id="fh7n4k"
docker compose up -d
```

Kiểm tra container:

```bash id="s2mt8x"
docker ps
```

---

## 2. Import SQL

Kết nối:

```text id="blq6oe"
Host: localhost
Port: 3307
User: root
Password: 123456
Database: Omnilogi
```

Sau đó chạy file `.sql`.

---

## 3. Chạy backend

```bash id="q9as1m"
npm run dev
```

Server chạy:

```text id="pr3xt6"
http://localhost:8080
```

---

# API Endpoints

## Product Module

```http id="ql5c7n"
GET    /api/products
GET    /api/products/:id
GET    /api/products/:id/recommendations
POST   /api/products
PUT    /api/products/:id
DELETE /api/products/:id
```

---

## Store Module

```http id="e3kr4t"
GET /api/stores/revenue-stats
```

---

## Customer Module

```http id="s9dv6f"
GET /api/customers/:id/tier
```


# Response Format

## Success

```json id="rlx4sy"
{
  "success": true,
  "data": [],
  "message": "OK"
}
```

## Error

```json id="gc2k4f"
{
  "success": false,
  "message": "Error message"
}
```


