import express from 'express';
import * as storeController from '../controllers/storeController.js';

const router = express.Router();

//Get revenue stats
router.get('/revenue-stats', storeController.getStoreRevenueStats);

export default router;