const express = require('express');
const router = express.Router();
const service = require('./service');

// GET /api/v1/module_master
router.get('/', async (req, res) => {
  try {
    const { search, category } = req.query;
    const modules = await service.getAllModules(search, category);
    res.json({ success: true, data: modules });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/v1/module_master/role-permissions/:roleId
router.get('/role-permissions/:roleId', async (req, res) => {
  try {
    const perms = await service.getRolePermissions(req.params.roleId);
    res.json({ success: true, data: perms });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/module_master/role-permissions/:roleId
router.post('/role-permissions/:roleId', async (req, res) => {
  try {
    const { permissions } = req.body;
    if (!Array.isArray(permissions)) {
      return res.status(400).json({ success: false, error: 'Permissions must be an array' });
    }
    const perms = await service.saveRolePermissions(req.params.roleId, permissions);
    res.json({ success: true, data: perms, message: 'Permissions saved successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// GET /api/v1/module_master/:id
router.get('/:id', async (req, res) => {
  try {
    const moduleItem = await service.getModuleById(req.params.id);
    if (!moduleItem) return res.status(404).json({ success: false, error: 'Module not found' });
    res.json({ success: true, data: moduleItem });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST /api/v1/module_master
router.post('/', async (req, res) => {
  try {
    const moduleItem = await service.createModule(req.body);
    res.status(201).json({ success: true, data: moduleItem });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// PUT /api/v1/module_master/:id
router.put('/:id', async (req, res) => {
  try {
    const moduleItem = await service.updateModule(req.params.id, req.body);
    res.json({ success: true, data: moduleItem });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// DELETE /api/v1/module_master/:id
router.delete('/:id', async (req, res) => {
  try {
    await service.deleteModule(req.params.id);
    res.json({ success: true, message: 'Module deleted successfully' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
