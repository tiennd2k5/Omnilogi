import { pool } from '../config/database.js';

export const getAllDrivers = async () => {
    const [rows] = await pool.query(
        `SELECT d.User_ID,
                u.User_name,
                u.First_name,
                u.Last_name,
                d.License_num,
                d.Vehicle_type,
                d.Driver_status,
                d.Total_deliveries
         FROM DRIVER d
         JOIN \`USER\` u ON u.User_ID = d.User_ID
         ORDER BY d.User_ID`
    );

    return rows;
};

export const getDriverById = async (id) => {
    const [rows] = await pool.query(
        `SELECT d.User_ID,
                u.User_name,
                u.First_name,
                u.Last_name,
                d.License_num,
                d.Vehicle_type,
                d.Driver_status,
                d.Total_deliveries
         FROM DRIVER d
         JOIN \`USER\` u ON u.User_ID = d.User_ID
         WHERE d.User_ID = ?`,
        [id]
    );

    return rows[0];
};

export const getDriverDeliveryStats = async (id) => {
    const [rows] = await pool.query(
        `SELECT d.User_ID,
                d.Total_deliveries,
                COUNT(s.Shipment_ID) AS Delivered_shipments
         FROM DRIVER d
         LEFT JOIN SHIPMENT s
           ON s.Driver_ID = d.User_ID
          AND s.Status = 'Delivered'
         WHERE d.User_ID = ?
         GROUP BY d.User_ID, d.Total_deliveries`,
        [id]
    );

    return rows[0];
};
