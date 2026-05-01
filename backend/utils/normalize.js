export const emptyToNull = (value) => {
    if (value === undefined || value === null) {
        return null;
    }

    if (typeof value === 'string' && value.trim() === '') {
        return null;
    }

    return value;
};
