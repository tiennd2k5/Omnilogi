const connection = require('../config/database');

const getHomePage = (req, res) => {
    return res.render('home.ejs');
};
const getHelloPage = (req, res) => {
    res.render('sample.ejs', { name: 'Tien' });
};

module.exports = { getHomePage, getHelloPage };