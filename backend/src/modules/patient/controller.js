const patientService = require('./service');

class PatientController {
  async getAll(req, res) {
    try {
      const { search = '', department = '', patient_type = '', status = 'all' } = req.query;
      const data = await patientService.getAllPatients(search, department, patient_type, status);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getOpdList(req, res) {
    try {
      const { search = '', department = '' } = req.query;
      const data = await patientService.getOpdList(search, department);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getIndoorList(req, res) {
    try {
      const { search = '', department = '' } = req.query;
      const data = await patientService.getIndoorList(search, department);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async generateCode(req, res) {
    try {
      const { department = 'Ayurvedic', patient_type = 'OPD' } = req.query;
      const code = await patientService.generateNextCode(department, patient_type);
      res.json({ success: true, code });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const data = await patientService.getPatientById(id);
      if (!data) {
        return res.status(404).json({ success: false, error: 'Patient not found' });
      }
      res.json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async create(req, res) {
    try {
      const data = await patientService.createPatient(req.body);
      res.status(201).json({ success: true, message: 'Patient registered successfully', data });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const data = await patientService.updatePatient(id, req.body);
      res.json({ success: true, message: 'Patient updated successfully', data });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await patientService.deletePatient(id);
      res.json({ success: true, message: 'Patient deleted successfully' });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }
}

module.exports = new PatientController();
