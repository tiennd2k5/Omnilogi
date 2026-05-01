import {pool} from '../config/database.js';
import { emptyToNull } from '../utils/normalize.js';
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
        ].map(emptyToNull)
    );

    return rows[0];
};
