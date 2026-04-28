import express from 'express';
import productRoutes from './productRoutes.js';
import storeRoutes from './storeRoutes.js';
import customerRoutes from './customerRoutes.js';

const router = express.Router();

router.use('/products', productRoutes);
router.use('/stores', storeRoutes);
router.use('/customers', customerRoutes);

// //Test route
// router.get("/", (req, res) => {
//     res.send("hello api route");
// });

export default router;