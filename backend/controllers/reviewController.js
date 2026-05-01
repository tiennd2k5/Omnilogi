import * as reviewService from '../services/reviewServices.js';
import { success } from '../utils/response.js';

export const getAllReviews = async (req, res, next) => {
    try {
        const data = await reviewService.getAllReviews(req.query);
        return success(res, data, 'Lấy danh sách review thành công');
    } catch (err) {
        next(err);
    }
};

export const getReviewById = async (req, res, next) => {
    try {
        const data = await reviewService.getReviewById(req.params.id);

        if (!data) {
            const error = new Error('Không tìm thấy review');
            error.statusCode = 404;
            throw error;
        }

        return success(res, data, 'Lấy chi tiết review thành công');
    } catch (err) {
        next(err);
    }
};

export const getReviewableItems = async (req, res, next) => {
    try {
        const data = await reviewService.getReviewableItems(req.query);
        return success(res, data, 'Lấy danh sách sản phẩm có thể review thành công');
    } catch (err) {
        next(err);
    }
};

export const insertReview = async (req, res, next) => {
    try {
        const data = await reviewService.insertReview(req.body);
        return success(res, data, 'Thêm review thành công');
    } catch (err) {
        next(err);
    }
};

export const deleteReview = async (req, res, next) => {
    try {
        const data = await reviewService.deleteReview(req.params.id);
        return success(res, data, 'Xóa review thành công');
    } catch (err) {
        next(err);
    }
};
