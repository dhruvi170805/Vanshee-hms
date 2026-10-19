const express = require('express');
const router = express.Router();
const supplierController = require('./controller');

router.get('/', (req, res) => supplierController.getAll(req, res));
router.get('/:id', (req, res) => supplierController.getById(req, res));
router.post('/', (req, res) => supplierController.create(req, res));
router.put('/:id', (req, res) => supplierController.update(req, res));
router.delete('/:id', (req, res) => supplierController.delete(req, res));

module.exports = router;
