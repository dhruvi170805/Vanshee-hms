const db = require('../../config/database');

class AppointmentService {
  async getAllAppointments(date = '', department = '', status = 'all') {
    let sql = 'SELECT * FROM appointments WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (date) {
      sql += ` AND appointment_date = $${paramIndex}`;
      params.push(date);
      paramIndex++;
    }

    if (department && department !== 'all') {
      sql += ` AND department = $${paramIndex}`;
      params.push(department);
      paramIndex++;
    }

    if (status && status !== 'all') {
      sql += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    sql += ' ORDER BY appointment_date DESC, token_number ASC';
    return await db.query(sql, params);
  }

  async getAppointmentById(id) {
    const rows = await db.query('SELECT * FROM appointments WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async createAppointment(data) {
    const {
      patient_id,
      patient_code,
      patient_name,
      department = 'Ayurvedic',
      doctor_name,
      appointment_date,
      appointment_time,
      reason = 'Routine Checkup',
      status = 'Scheduled'
    } = data;

    if (!patient_name) {
      throw new Error('Patient name is required for appointment.');
    }

    const apptDate = appointment_date || new Date().toISOString().split('T')[0];
    const apptTime = appointment_time || '10:00 AM';

    // Calculate next token for this date & department
    const tokenRes = await db.query(
      'SELECT COUNT(*) as count FROM appointments WHERE appointment_date = $1 AND department = $2',
      [apptDate, department]
    );
    const tokenNumber = (tokenRes[0]?.count || 0) + 1;

    const res = await db.query(
      `INSERT INTO appointments (patient_id, patient_code, patient_name, department, doctor_name, appointment_date, appointment_time, token_number, reason, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [
        patient_id || null,
        patient_code || '',
        patient_name,
        department,
        doctor_name || (department.toLowerCase().includes('ayu') ? 'Dr. H. N. Patel' : 'Dr. Priya Desai (PT)'),
        apptDate,
        apptTime,
        tokenNumber,
        reason,
        status
      ]
    );

    const newId = res[0]?.id;

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['BOOK_APPOINTMENT', `Scheduled token #${tokenNumber} for ${patient_name} in ${department} dept.`]
    );

    return await this.getAppointmentById(newId);
  }

  async updateAppointmentStatus(id, status) {
    await db.query(
      'UPDATE appointments SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      [status, id]
    );
    return await this.getAppointmentById(id);
  }

  async deleteAppointment(id) {
    await db.query('DELETE FROM appointments WHERE id = $1', [id]);
    return true;
  }
}

module.exports = new AppointmentService();
