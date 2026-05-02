import * as productService from '../services/productServices.js';
import { success } from '../utils/response.js';

export const getAllProducts = async (req, res, next) => {
    try {
        const data = await productService.getAllProducts(req.query);
        return success(res, data, 'Lấy danh sách sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

export const getProductById = async (req, res, next) => {
    try {
        const data = await productService.getProductById(req.params.id);

        if (!data) {
            const err = new Error('Không tìm thấy sản phẩm');
            err.statusCode = 404;
            throw err;
        }

        return success(res, data, 'Lấy chi tiết sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

export const insertProduct = async (req, res, next) => {
    try {
        const data = await productService.insertProduct(req.body);
        return success(res, data, 'Thêm sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

export const updateProduct = async (req, res, next) => {
    try {
        const data = await productService.updateProduct(req.params.id, req.body);
        return success(res, data, 'Cập nhật sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

export const deleteProduct = async (req, res, next) => {
    try {
        const data = await productService.deleteProduct(req.params.id);
        return success(res, data, 'Xóa sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

export const getRecommendations = async (req, res, next) => {
    try {
        const data = await productService.getRecommendations(
            req.params.id,
            req.query.min_confidence || 40
        );

        return success(res, data, 'Lấy danh sách sản phẩm gợi ý thành công');
    } catch (err) {
        next(err);
    }
};
