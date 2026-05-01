import { pool } from '../config/database.js';
import { emptyToNull } from '../utils/normalize.js';

export const SHIPMENT_STATUSES = ['Pending', 'Shipping', 'Delivered'];

const normalizeStatus = (status) => {
    if (typeof status !== 'string') {
        return status;
    }

    const matchedStatus = SHIPMENT_STATUSES.find(
        (item) => item.toLowerCase() === status.trim().toLowerCase()
    );

    return matchedStatus || status;
};

const createHttpError = (message, statusCode) => {
    const err = new Error(message);
    err.statusCode = statusCode;
    return err;
};

const validateStatus = (status, required = true) => {
    if (!required && status === undefined) {
        return undefined;
    }

    if (required && (status === undefined || status === null || status === '')) {
        throw createHttpError('Trạng thái shipment là bắt buộc', 400);
    }

    const normalizedStatus = normalizeStatus(status);

    if (!SHIPMENT_STATUSES.includes(normalizedStatus)) {
        throw createHttpError(
            `Trạng thái shipment không hợp lệ. Chỉ nhận: ${SHIPMENT_STATUSES.join(', ')}`,
            400
        );
    }

    return normalizedStatus;
};

const ensureShipmentExists = async (id) => {
    const [rows] = await pool.query(
        `SELECT Shipment_ID
         FROM SHIPMENT
         WHERE Shipment_ID = ?`,
        [id]
    );

    if (!rows[0]) {
        throw createHttpError('Không tìm thấy shipment', 404);
    }
};

export const getShipmentStatuses = () => SHIPMENT_STATUSES;

export const getAllShipments = async (query) => {
    const {
        status,
        driver_id,
        order_id
    } = query;

    const normalizedStatus = emptyToNull(status) ? validateStatus(status) : null;
    const driverId = emptyToNull(driver_id);
    const orderId = emptyToNull(order_id);

    const [rows] = await pool.query(
        `SELECT Shipment_ID, Driver_ID, Order_ID, Status
         FROM SHIPMENT
         WHERE (? IS NULL OR Status = ?)
           AND (? IS NULL OR Driver_ID = ?)
           AND (? IS NULL OR Order_ID = ?)
         ORDER BY Shipment_ID DESC`,
        [
            normalizedStatus,
            normalizedStatus,
            driverId,
            driverId,
            orderId,
            orderId
        ]
    );

    return rows;
};

export const getShipmentById = async (id) => {
    const [rows] = await pool.query(
        `SELECT Shipment_ID, Driver_ID, Order_ID, Status
         FROM SHIPMENT
         WHERE Shipment_ID = ?`,
        [id]
    );

    return rows[0];
};

export const insertShipment = async (data) => {
    const {
        driver_id,
        order_id,
        status
    } = data;

    const driverId = emptyToNull(driver_id);
    const orderId = emptyToNull(order_id);

    if (!driverId || !orderId) {
        throw createHttpError('driver_id và order_id là bắt buộc', 400);
    }

    const normalizedStatus = validateStatus(status);

    const [result] = await pool.query(
        `INSERT INTO SHIPMENT (Driver_ID, Order_ID, Status)
         VALUES (?, ?, ?)`,
        [driverId, orderId, normalizedStatus]
    );

    return getShipmentById(result.insertId);
};

export const updateShipment = async (id, data) => {
    await ensureShipmentExists(id);

    const {
        driver_id,
        order_id,
        status
    } = data;

    const normalizedStatus = validateStatus(status, false);
    const driverId = emptyToNull(driver_id);
    const orderId = emptyToNull(order_id);

    const [result] = await pool.query(
        `UPDATE SHIPMENT
         SET Driver_ID = COALESCE(?, Driver_ID),
             Order_ID = COALESCE(?, Order_ID),
             Status = COALESCE(?, Status)
         WHERE Shipment_ID = ?`,
        [
            driverId,
            orderId,
            normalizedStatus ?? null,
            id
        ]
    );

    if (result.affectedRows === 0) {
        throw createHttpError('Không thể cập nhật shipment', 400);
    }

    return getShipmentById(id);
};

export const deleteShipment = async (id) => {
    await ensureShipmentExists(id);

    const [result] = await pool.query(
        `DELETE FROM SHIPMENT
         WHERE Shipment_ID = ?`,
        [id]
    );

    if (result.affectedRows === 0) {
        throw createHttpError('Không thể xóa shipment', 400);
    }

    return { shipment_id: Number(id) };
};
