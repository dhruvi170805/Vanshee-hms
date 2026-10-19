const classificationService = require('./service');

class ClassificationController {
  async getAll(req, res) {
    try {
      const { search = '', status = 'all' } = req.query;
      const data = await classificationService.getAllClassifications(search, status);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const data = await classificationService.getClassificationById(id);
      if (!data) {
        return res.status(404).json({ success: false, error: 'Classification not found' });
      }
      res.json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async create(req, res) {
    try {
      const { code, name, description, is_active } = req.body;
      if (!code || !name) {
        return res.status(400).json({ success: false, error: 'Code and Name are required fields.' });
      }
      const newClassification = await classificationService.createClassification({ code, name, description, is_active });
      res.status(201).json({ success: true, message: 'Classification created successfully', data: newClassification });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const updated = await classificationService.updateClassification(id, req.body);
      res.json({ success: true, message: 'Classification updated successfully', data: updated });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await classificationService.deleteClassification(id);
      res.json({ success: true, message: 'Classification deleted successfully' });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }
}

module.exports = new ClassificationController();
