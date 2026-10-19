const appointmentService = require('./service');

class AppointmentController {
  async getAll(req, res) {
    try {
      const { date = '', department = '', status = 'all' } = req.query;
      const data = await appointmentService.getAllAppointments(date, department, status);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const data = await appointmentService.getAppointmentById(id);
      if (!data) {
        return res.status(404).json({ success: false, error: 'Appointment not found' });
      }
      res.json({ success: true, data });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
  }

  async create(req, res) {
    try {
      const data = await appointmentService.createAppointment(req.body);
      res.status(201).json({ success: true, message: 'Appointment booked successfully', data });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async updateStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;
      const data = await appointmentService.updateAppointmentStatus(id, status);
      res.json({ success: true, message: 'Appointment status updated', data });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await appointmentService.deleteAppointment(id);
      res.json({ success: true, message: 'Appointment cancelled/deleted' });
    } catch (err) {
      res.status(400).json({ success: false, error: err.message });
    }
  }
}

module.exports = new AppointmentController();
