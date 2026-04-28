import express from 'express';
import * as customerController from '../controllers/customerController.js';

const router = express.Router();
router.get('/:id/tier', customerController.getCustomerTier);

export default router;