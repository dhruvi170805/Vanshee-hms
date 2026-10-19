const express = require('express');
const router = express.Router();
const service = require('./service');

// GET /api/v1/room
router.get('/', async (req, res) => {
  try {
    const { search, status } = req.query;
    const rooms = await service.getAllRooms(search, status);
    res.json({ success: true, data: rooms });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/room/:id
router.get('/:id', async (req, res) => {
  try {
    const room = await service.getRoomById(req.params.id);
    if (!room) return res.status(404).json({ success: false, error: 'Room not found' });
    res.json({ success: true, data: room });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/room
router.post('/', async (req, res) => {
  try {
    const room = await service.createRoom(req.body);
    res.status(201).json({ success: true, data: room });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// PUT /api/v1/room/:id
router.put('/:id', async (req, res) => {
  try {
    const room = await service.updateRoom(req.params.id, req.body);
    res.json({ success: true, data: room });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// DELETE /api/v1/room/:id
router.delete('/:id', async (req, res) => {
  try {
    await service.deleteRoom(req.params.id);
    res.json({ success: true, message: 'Room deleted successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
