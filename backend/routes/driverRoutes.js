import express from 'express';
import * as driverController from '../controllers/driverController.js';

const router = express.Router();

router.get('/', driverController.getAllDrivers);
router.get('/:id/delivery-stats', driverController.getDriverDeliveryStats);
router.get('/:id', driverController.getDriverById);

export default router;
