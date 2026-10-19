const express = require('express');
const router = express.Router();
const appointmentController = require('./controller');

router.get('/', (req, res) => appointmentController.getAll(req, res));
router.get('/:id', (req, res) => appointmentController.getById(req, res));
router.post('/', (req, res) => appointmentController.create(req, res));
router.put('/:id/status', (req, res) => appointmentController.updateStatus(req, res));
router.delete('/:id', (req, res) => appointmentController.delete(req, res));

module.exports = router;
