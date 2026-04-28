import * as productService from '../services/productServices.js';
import {success, error} from '../utils/response.js';

//Get all products
export const getAllProducts = async (req, res, next) => {
    try {
        const data = await productService.getAllProducts(req.query);
        return success(res, data, 'Lấy danh sách sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

//Get product by id
export const getProductById = async (req, res, next) => {
    try {
        const data = await productService.getProductById(req.params.id);

        if (!data) {
            const error = new Error('Không tìm thấy sản phẩm');
            error.statusCode = 404;
            throw error;
        }

        return success(res, data, 'Lấy chi tiết sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

//Insert new product
export const insertProduct = async (req, res, next) => {
    try {
        const data = await productService.insertProduct(req.body);
        return success(res, data, 'Thêm sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

//Update product
export const updateProduct = async (req, res, next) => {
    try {
        const data = await productService.updateProduct(
            req.params.id,
            req.body
        );

        return success(res, data, 'Cập nhật sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

//Delete product
export const deleteProduct = async (req, res, next) => {
    try {
        const data = await productService.deleteProduct(req.params.id);
        return success(res, data, 'Xóa sản phẩm thành công');
    } catch (err) {
        next(err);
    }
};

//Get product recommendations
export const getRecommendations = async (req, res, next) => {
    try {
        const data = await productService.getRecommendations(
            req.params.id,
            req.query.min_confidence || 40
        );

        return success(
            res,
            data,
            'Lấy danh sách sản phẩm gợi ý thành công'
        );
    } catch (err) {
        next(err);
    }
};