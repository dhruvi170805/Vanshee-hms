const express = require('express');
const router = express.Router();
const service = require('./service');

// GET /api/v1/role
router.get('/', async (req, res) => {
  try {
    const roles = await service.getAllRoles();
    res.json({ success: true, data: roles });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/role/:id
router.get('/:id', async (req, res) => {
  try {
    const role = await service.getRoleById(req.params.id);
    if (!role) return res.status(404).json({ success: false, error: 'Role not found' });
    res.json({ success: true, data: role });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/role
router.post('/', async (req, res) => {
  try {
    const role = await service.createRole(req.body);
    res.status(201).json({ success: true, data: role });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// PUT /api/v1/role/:id
router.put('/:id', async (req, res) => {
  try {
    const role = await service.updateRole(req.params.id, req.body);
    res.json({ success: true, data: role });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// DELETE /api/v1/role/:id
router.delete('/:id', async (req, res) => {
  try {
    await service.deleteRole(req.params.id);
    res.json({ success: true, message: 'Role deleted successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
