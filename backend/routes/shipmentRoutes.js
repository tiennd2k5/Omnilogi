import express from 'express';
import * as shipmentController from '../controllers/shipmentController.js';

const router = express.Router();

router.get('/statuses', shipmentController.getShipmentStatuses);
router.get('/', shipmentController.getAllShipments);
router.get('/:id', shipmentController.getShipmentById);
router.post('/', shipmentController.insertShipment);
router.put('/:id', shipmentController.updateShipment);
router.delete('/:id', shipmentController.deleteShipment);

export default router;
