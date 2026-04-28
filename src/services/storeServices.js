import {pool} from '../config/database.js';
//Get revenue stats
export const getStoreRevenueStats = async (query) => {
    const {
        store_id = null,
        from_date = null,
        to_date = null,
        min_revenue = null
    } = query;

    const [rows] = await pool.query(
        `CALL sp_get_store_revenue_stats(?, ?, ?, ?)`,
        [
            store_id,
            from_date,
            to_date,
            min_revenue
        ]
    );

    return rows[0];
};