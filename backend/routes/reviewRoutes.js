import express from 'express';
import * as reviewController from '../controllers/reviewController.js';

const router = express.Router();

router.get('/reviewable-items', reviewController.getReviewableItems);
router.get('/', reviewController.getAllReviews);
router.get('/:id', reviewController.getReviewById);
router.post('/', reviewController.insertReview);
router.delete('/:id', reviewController.deleteReview);

export default router;
