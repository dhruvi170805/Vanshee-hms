const express = require('express');
const router = express.Router();
const controller = require('./controller');

router.get('/stats', (req, res) => controller.getStats(req, res));

module.exports = router;
