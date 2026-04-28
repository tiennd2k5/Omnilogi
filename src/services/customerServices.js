import { pool } from '../config/database.js';

export const getCustomerTier = async (customerId) => {
    const [rows] = await pool.query(
        `SELECT fn_get_customer_tier(?) AS tier`,
        [customerId]
    );

    return rows[0];
};