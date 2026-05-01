import { pool } from '../config/database.js';
import { emptyToNull } from '../utils/normalize.js';

const createHttpError = (message, statusCode) => {
    const err = new Error(message);
    err.statusCode = statusCode;
    return err;
};

const validateRating = (rating) => {
    const numericRating = Number(rating);

    if (!Number.isInteger(numericRating) || numericRating < 1 || numericRating > 5) {
        throw createHttpError('Rating phải là số nguyên từ 1 đến 5', 400);
    }

    return numericRating;
};

export const getAllReviews = async (query) => {
    const {
        customer_id,
        order_id,
        item_id
    } = query;

    const customerId = emptyToNull(customer_id);
    const orderId = emptyToNull(order_id);
    const itemId = emptyToNull(item_id);

    const [rows] = await pool.query(
        `SELECT Review_ID,
                Order_ID,
                Item_ID,
                Customer_ID,
                Rating,
                Comment,
                Image,
                Review_date
         FROM REVIEW
         WHERE (? IS NULL OR Customer_ID = ?)
           AND (? IS NULL OR Order_ID = ?)
           AND (? IS NULL OR Item_ID = ?)
         ORDER BY Review_ID DESC`,
        [
            customerId,
            customerId,
            orderId,
            orderId,
            itemId,
            itemId
        ]
    );

    return rows;
};

export const getReviewById = async (id) => {
    const customerId = emptyToNull(customer_id);

    const [rows] = await pool.query(
        `SELECT Review_ID,
                Order_ID,
                Item_ID,
                Customer_ID,
                Rating,
                Comment,
                Image,
                Review_date
         FROM REVIEW
         WHERE Review_ID = ?`,
        [id]
    );

    return rows[0];
};

export const getReviewableItems = async (query) => {
    const { customer_id } = query;

    const [rows] = await pool.query(
        `SELECT oi.Item_ID,
                oi.Order_ID,
                o.Customer_ID,
                oi.Product_ID,
                p.\`Name\` AS Product_name,
                oi.Quantity,
                oi.Price_of_purchase
         FROM ORDER_ITEM oi
         JOIN \`ORDER\` o ON o.Order_ID = oi.Order_ID
         JOIN PRODUCT p ON p.Product_ID = oi.Product_ID
         LEFT JOIN REVIEW r
           ON r.Order_ID = oi.Order_ID
          AND r.Item_ID = oi.Item_ID
         WHERE o.Order_status = 'Completed'
           AND r.Review_ID IS NULL
           AND (? IS NULL OR o.Customer_ID = ?)
         ORDER BY oi.Order_ID DESC, oi.Item_ID DESC`,
        [
            customerId,
            customerId
        ]
    );

    return rows;
};

export const insertReview = async (data) => {
    const {
        order_id,
        item_id,
        customer_id,
        rating,
        comment = null,
        image = null,
        review_date = null
    } = data;

    const orderId = emptyToNull(order_id);
    const itemId = emptyToNull(item_id);
    const customerId = emptyToNull(customer_id);

    if (!orderId || !itemId || !customerId || rating === undefined) {
        throw createHttpError('order_id, item_id, customer_id và rating là bắt buộc', 400);
    }

    const numericRating = validateRating(rating);

    const [result] = await pool.query(
        `INSERT INTO REVIEW (Order_ID, Item_ID, Customer_ID, Rating, Comment, Image, Review_date)
         VALUES (?, ?, ?, ?, ?, ?, COALESCE(?, CURDATE()))`,
        [
            orderId,
            itemId,
            customerId,
            numericRating,
            emptyToNull(comment),
            emptyToNull(image),
            emptyToNull(review_date)
        ]
    );

    return getReviewById(result.insertId);
};

export const deleteReview = async (id) => {
    const [result] = await pool.query(
        `DELETE FROM REVIEW
         WHERE Review_ID = ?`,
        [id]
    );

    if (result.affectedRows === 0) {
        throw createHttpError('Không tìm thấy review', 404);
    }

    return { review_id: Number(id) };
};
