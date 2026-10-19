const express = require('express');
const router = express.Router();
const service = require('./service');

// GET /api/v1/lab_report
router.get('/', async (req, res) => {
  try {
    const { search, status } = req.query;
    const reports = await service.getAllReports(search, status);
    res.json({ success: true, data: reports });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/lab_report/generate-no
router.get('/generate-no', async (req, res) => {
  try {
    const reportNo = await service.generateReportNo();
    res.json({ success: true, report_no: reportNo });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/lab_report/:id
router.get('/:id', async (req, res) => {
  try {
    const report = await service.getReportById(req.params.id);
    if (!report) return res.status(404).json({ success: false, error: 'Lab Report not found' });
    res.json({ success: true, data: report });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/lab_report
router.post('/', async (req, res) => {
  try {
    const report = await service.createReport(req.body);
    res.status(201).json({ success: true, data: report });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// PUT /api/v1/lab_report/:id
router.put('/:id', async (req, res) => {
  try {
    const report = await service.updateReport(req.params.id, req.body);
    res.json({ success: true, data: report });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// DELETE /api/v1/lab_report/:id
router.delete('/:id', async (req, res) => {
  try {
    await service.deleteReport(req.params.id);
    res.json({ success: true, message: 'Lab report deleted successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
