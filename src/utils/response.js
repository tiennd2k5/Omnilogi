export const success = (res, data, message = 'OK') => {
    return res.json({
        success: true,
        data,
        message
    });
};

export const error = (res, message = 'Error', statusCode = 500) => {
    return res.status(statusCode).json({
        success: false,
        message
    });
}