import {pool} from '../config/database.js';

//Get all products
export const getAllProducts = async (query) => {
    const {
        status = null,
        category_id = null,
        search = null
    } = query;

    const [rows] = await pool.query(
        `CALL sp_get_all_products(?, ?, ?)`,
        [status, category_id, search]
    );

    return rows[0];
};

//Get product by id
export const getProductById = async (id) => {
    const [rows] = await pool.query(`
        SELECT *
        FROM PRODUCT
        WHERE Product_ID = ?
    `, [id]);

    return rows[0];
};

//Get recommended products
export const getRecommendedProducts = async (productId, minConfidence) => {
    const [rows] = await pool.query(
        "SELECT fn_recommend_products(?, ?) AS result",
        [productId, minConfidence]
    );
    return rows[0].result;
};

//Insert new product
export const insertProduct = async (data) => {
    const {
        category_id,
        name,
        desc,
        brand,
        image_url,
        status,
        created_by_id
    } = data;

    const [rows] = await pool.query(
        `CALL sp_insert_product(?, ?, ?, ?, ?, ?, ?)`,
        [
            category_id,
            name,
            desc,
            brand,
            image_url,
            status,
            created_by_id
        ]
    );

    return rows[0][0];
};

//Update product
export const updateProduct = async (id, data) => {
    const {
        category_id,
        name,
        desc,
        brand,
        image_url,
        status
    } = data;

    const [rows] = await pool.query(
        `CALL sp_update_product(?, ?, ?, ?, ?, ?, ?)`,
        [
            id,
            category_id,
            name,
            desc,
            brand,
            image_url,
            status
        ]
    );

    return rows[0][0];
};

//Delete product
export const deleteProduct = async (id) => {
    const [rows] = await pool.query(
        `CALL sp_delete_product(?)`,
        [id]
    );

    return rows[0][0];
};

//get product recommendations
export const getRecommendations = async (productId, minConfidence = 40) => {
    const [rows] = await pool.query(
        `SELECT fn_recommend_products(?, ?) AS recommendations`,
        [productId, minConfidence]
    );

    return rows[0];
};