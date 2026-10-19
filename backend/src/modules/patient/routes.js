const express = require('express');
const router = express.Router();
const patientController = require('./controller');

router.get('/', (req, res) => patientController.getAll(req, res));
router.get('/opd-list', (req, res) => patientController.getOpdList(req, res));
router.get('/indoor-list', (req, res) => patientController.getIndoorList(req, res));
router.get('/generate-code', (req, res) => patientController.generateCode(req, res));
router.get('/:id', (req, res) => patientController.getById(req, res));
router.post('/', (req, res) => patientController.create(req, res));
router.put('/:id', (req, res) => patientController.update(req, res));
router.delete('/:id', (req, res) => patientController.delete(req, res));

module.exports = router;
