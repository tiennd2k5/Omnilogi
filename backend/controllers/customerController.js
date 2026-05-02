import * as customerService from '../services/customerServices.js';
import { success } from '../utils/response.js';

export const getCustomerTier = async (req, res, next) => {
    try {
        const data = await customerService.getCustomerTier(req.params.id);
        return success(res, data, 'Lấy hạng khách hàng thành công');
    } catch (err) {
        next(err);
    }
};
