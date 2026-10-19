const express = require('express');
const router = express.Router();
const service = require('./service');

// GET /api/v1/user
router.get('/', async (req, res) => {
  try {
    const { search } = req.query;
    const users = await service.getAllUsers(search);
    res.json({ success: true, data: users });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/user/:id
router.get('/:id', async (req, res) => {
  try {
    const user = await service.getUserById(req.params.id);
    if (!user) return res.status(404).json({ success: false, error: 'User not found' });
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/user
router.post('/', async (req, res) => {
  try {
    const user = await service.createUser(req.body);
    res.status(201).json({ success: true, data: user });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// PUT /api/v1/user/:id
router.put('/:id', async (req, res) => {
  try {
    const user = await service.updateUser(req.params.id, req.body);
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// DELETE /api/v1/user/:id
router.delete('/:id', async (req, res) => {
  try {
    await service.deleteUser(req.params.id);
    res.json({ success: true, message: 'User deactivated successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
