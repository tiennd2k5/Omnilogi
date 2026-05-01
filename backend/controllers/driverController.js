import * as driverService from '../services/driverServices.js';
import { success } from '../utils/response.js';

export const getAllDrivers = async (req, res, next) => {
    try {
        const data = await driverService.getAllDrivers();
        return success(res, data, 'Lấy danh sách tài xế thành công');
    } catch (err) {
        next(err);
    }
};

export const getDriverById = async (req, res, next) => {
    try {
        const data = await driverService.getDriverById(req.params.id);

        if (!data) {
            const error = new Error('Không tìm thấy tài xế');
            error.statusCode = 404;
            throw error;
        }

        return success(res, data, 'Lấy thông tin tài xế thành công');
    } catch (err) {
        next(err);
    }
};

export const getDriverDeliveryStats = async (req, res, next) => {
    try {
        const data = await driverService.getDriverDeliveryStats(req.params.id);

        if (!data) {
            const error = new Error('Không tìm thấy tài xế');
            error.statusCode = 404;
            throw error;
        }

        return success(res, data, 'Lấy thống kê giao hàng của tài xế thành công');
    } catch (err) {
        next(err);
    }
};
