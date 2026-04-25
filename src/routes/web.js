const express = require('express');
const router = express.Router();
const { getHomePage, getHelloPage } = require('../controllers/homeController');

router.get('/', getHomePage);
router.get('/hello', getHelloPage);

module.exports = router;