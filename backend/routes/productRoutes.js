import express from 'express';
import * as productController from '../controllers/productController.js';

const router = express.Router();


router.get("/", productController.getAllProducts);
router.get('/:id', productController.getProductById);
router.post('/', productController.insertProduct);
router.put('/:id', productController.updateProduct);
router.delete('/:id', productController.deleteProduct);
router.get('/:id/recommendations', productController.getRecommendations);

// //Test route
// router.get("/", (req, res) => {
//     res.send("hello product route");
// });

export default router;