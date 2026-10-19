const purchaseService = require('./service');

class PurchaseController {
  async getAll(req, res) {
    try {
      const { search = '', supplier_id = '' } = req.query;
      const data = await purchaseService.getAllPurchases(search, supplier_id);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const data = await purchaseService.getPurchaseById(id);
      if (!data) {
        return res.status(404).json({ success: false, error: 'Purchase invoice not found' });
      }
      res.json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async create(req, res) {
    try {
      const data = await purchaseService.createPurchase(req.body);
      res.status(201).json({ success: true, message: 'Purchase invoice created and stock updated successfully', data });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await purchaseService.deletePurchase(id);
      res.json({ success: true, message: 'Purchase invoice deleted successfully' });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }
}

module.exports = new PurchaseController();
