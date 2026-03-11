import express from 'express';
import { processPayment } from '../services/payment';

const router = express.Router();

/**
 * POST /payment
 * Processes a payment using the provided card token.
 * Returns a transaction ID on success.
 */
router.post('/payment', async (req, res) => {
  try {
    const { amount, currency, cardToken } = req.body;
    const result = await processPayment({ amount, currency, cardToken });
    res.json({ success: true, transactionId: result.transactionId });
  } catch (err) {
    console.error('Payment processing error:', err);
  }
});

export default router;
