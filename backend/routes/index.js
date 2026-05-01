import express from 'express';
import productRoutes from './productRoutes.js';
import storeRoutes from './storeRoutes.js';
import customerRoutes from './customerRoutes.js';
import shipmentRoutes from './shipmentRoutes.js';
import driverRoutes from './driverRoutes.js';
import reviewRoutes from './reviewRoutes.js';

const router = express.Router();

router.use('/products', productRoutes);
router.use('/stores', storeRoutes);
router.use('/customers', customerRoutes);
router.use('/shipments', shipmentRoutes);
router.use('/drivers', driverRoutes);
router.use('/reviews', reviewRoutes);

// //Test route
// router.get("/", (req, res) => {
//     res.send("hello api route");
// });

export default router;
