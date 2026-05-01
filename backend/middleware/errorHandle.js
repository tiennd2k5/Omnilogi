import { error } from '../utils/response.js';

const errorHandler = (err, req, res, next) => {
    console.error('Error:', err.message);

    const mysqlClientErrorCodes = new Set([
        'ER_SIGNAL_EXCEPTION',
        'ER_DUP_ENTRY',
        'ER_NO_REFERENCED_ROW_2',
        'ER_ROW_IS_REFERENCED_2',
        'WARN_DATA_TRUNCATED',
        'ER_CHECK_CONSTRAINT_VIOLATED'
    ]);

    const statusCode = err.statusCode
        || (err.sqlState === '45000' || mysqlClientErrorCodes.has(err.code) ? 400 : 500);

    return error(
        res,
        err.message || 'Internal Server Error',
        statusCode
    );
};

export default errorHandler;
