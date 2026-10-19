const medicineService = require('./service');

class MedicineController {
  async getAll(req, res) {
    try {
      const data = await medicineService.getAllMedicines(req.query);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const data = await medicineService.getMedicineById(id);
      if (!data) {
        return res.status(404).json({ success: false, error: 'Medicine not found' });
      }
      res.json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async create(req, res) {
    try {
      const { classification_id, name, sku_code } = req.body;
      if (!classification_id || !name || !sku_code) {
        return res.status(400).json({ success: false, error: 'Classification ID, Name, and SKU Code are required fields.' });
      }
      const newMed = await medicineService.createMedicine(req.body);
      res.status(201).json({ success: true, message: 'Medicine added successfully', data: newMed });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const updated = await medicineService.updateMedicine(id, req.body);
      res.json({ success: true, message: 'Medicine updated successfully', data: updated });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await medicineService.deleteMedicine(id);
      res.json({ success: true, message: 'Medicine deleted successfully' });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }
}

module.exports = new MedicineController();
