const express = require('express');
const router = express.Router();
const purchaseController = require('./controller');

router.get('/', (req, res) => purchaseController.getAll(req, res));
router.get('/:id', (req, res) => purchaseController.getById(req, res));
router.post('/', (req, res) => purchaseController.create(req, res));
router.delete('/:id', (req, res) => purchaseController.delete(req, res));

module.exports = router;
