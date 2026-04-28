import * as storeService from '../services/storeServices.js';
import {success, error} from '../utils/response.js';

//Get revenue stats
export const getStoreRevenueStats = async (req, res, next) => {
    try {
        const data = await storeService.getStoreRevenueStats(req.query);

        return success(
            res,
            data,
            'Lấy thống kê doanh thu cửa hàng thành công'
        );
    } catch (err) {
        next(err);
    }
};