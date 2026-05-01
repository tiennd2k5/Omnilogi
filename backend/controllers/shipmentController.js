import * as shipmentService from '../services/shipmentServices.js';
import { success } from '../utils/response.js';

export const getShipmentStatuses = async (req, res, next) => {
    try {
        const data = shipmentService.getShipmentStatuses();
        return success(res, data, 'Lấy danh sách trạng thái shipment thành công');
    } catch (err) {
        next(err);
    }
};

export const getAllShipments = async (req, res, next) => {
    try {
        const data = await shipmentService.getAllShipments(req.query);
        return success(res, data, 'Lấy danh sách shipment thành công');
    } catch (err) {
        next(err);
    }
};

export const getShipmentById = async (req, res, next) => {
    try {
        const data = await shipmentService.getShipmentById(req.params.id);

        if (!data) {
            const error = new Error('Không tìm thấy shipment');
            error.statusCode = 404;
            throw error;
        }

        return success(res, data, 'Lấy chi tiết shipment thành công');
    } catch (err) {
        next(err);
    }
};

export const insertShipment = async (req, res, next) => {
    try {
        const data = await shipmentService.insertShipment(req.body);
        return success(res, data, 'Thêm shipment thành công');
    } catch (err) {
        next(err);
    }
};

export const updateShipment = async (req, res, next) => {
    try {
        const data = await shipmentService.updateShipment(req.params.id, req.body);
        return success(res, data, 'Cập nhật shipment thành công');
    } catch (err) {
        next(err);
    }
};

export const deleteShipment = async (req, res, next) => {
    try {
        const data = await shipmentService.deleteShipment(req.params.id);
        return success(res, data, 'Xóa shipment thành công');
    } catch (err) {
        next(err);
    }
};
