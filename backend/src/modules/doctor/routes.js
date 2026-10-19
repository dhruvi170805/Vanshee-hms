const express = require('express');
const router = express.Router();
const service = require('./service');

// GET /api/v1/doctor
router.get('/', async (req, res) => {
  try {
    const { search, department } = req.query;
    const doctors = await service.getAllDoctors(search, department);
    res.json({ success: true, data: doctors });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/doctor/generate-code
router.get('/generate-code', async (req, res) => {
  try {
    const code = await service.generateDoctorCode();
    res.json({ success: true, code });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/doctor/:id
router.get('/:id', async (req, res) => {
  try {
    const doctor = await service.getDoctorById(req.params.id);
    if (!doctor) return res.status(404).json({ success: false, error: 'Doctor not found' });
    res.json({ success: true, data: doctor });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/doctor
router.post('/', async (req, res) => {
  try {
    const doctor = await service.createDoctor(req.body);
    res.status(201).json({ success: true, data: doctor });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// PUT /api/v1/doctor/:id
router.put('/:id', async (req, res) => {
  try {
    const doctor = await service.updateDoctor(req.params.id, req.body);
    res.json({ success: true, data: doctor });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// DELETE /api/v1/doctor/:id
router.delete('/:id', async (req, res) => {
  try {
    await service.deleteDoctor(req.params.id);
    res.json({ success: true, message: 'Doctor deactivated successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
