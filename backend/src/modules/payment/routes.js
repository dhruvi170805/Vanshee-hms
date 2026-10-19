const express = require('express');
const router = express.Router();
const service = require('./service');

// GET /api/v1/payment/summary
router.get('/summary', async (req, res) => {
  try {
    const summary = await service.getPaymentSummary();
    res.json({ success: true, data: summary });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/payment/generate-receipt
router.get('/generate-receipt', async (req, res) => {
  try {
    const receiptNo = await service.generateReceiptNo();
    res.json({ success: true, receipt_no: receiptNo });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/payment
router.get('/', async (req, res) => {
  try {
    const { search, status } = req.query;
    const payments = await service.getAllPayments(search, status);
    res.json({ success: true, data: payments });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/payment/:id
router.get('/:id', async (req, res) => {
  try {
    const payment = await service.getPaymentById(req.params.id);
    if (!payment) return res.status(404).json({ success: false, error: 'Payment record not found' });
    res.json({ success: true, data: payment });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/payment
router.post('/', async (req, res) => {
  try {
    const payment = await service.createPayment(req.body);
    res.status(201).json({ success: true, data: payment });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// PUT /api/v1/payment/:id
router.put('/:id', async (req, res) => {
  try {
    const payment = await service.updatePayment(req.params.id, req.body);
    res.json({ success: true, data: payment });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// DELETE /api/v1/payment/:id
router.delete('/:id', async (req, res) => {
  try {
    await service.deletePayment(req.params.id);
    res.json({ success: true, message: 'Payment record deleted successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
