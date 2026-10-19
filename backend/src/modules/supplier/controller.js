const supplierService = require('./service');

class SupplierController {
  async getAll(req, res) {
    try {
      const { search = '', status = 'all' } = req.query;
      const data = await supplierService.getAllSuppliers(search, status);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const data = await supplierService.getSupplierById(id);
      if (!data) {
        return res.status(404).json({ success: false, error: 'Supplier not found' });
      }
      res.json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async create(req, res) {
    try {
      const { name, phone } = req.body;
      if (!name || !name.trim()) {
        return res.status(400).json({ success: false, error: 'Supplier name is required.' });
      }
      if (!phone || !phone.trim()) {
        return res.status(400).json({ success: false, error: 'Compulsory phone number is required.' });
      }
      const data = await supplierService.createSupplier(req.body);
      res.status(201).json({ success: true, message: 'Supplier created successfully', data });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const data = await supplierService.updateSupplier(id, req.body);
      res.json({ success: true, message: 'Supplier updated successfully', data });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await supplierService.deleteSupplier(id);
      res.json({ success: true, message: 'Supplier deleted successfully' });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }
}

module.exports = new SupplierController();
