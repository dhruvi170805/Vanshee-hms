const db = require('../../config/database');

class PatientService {
  async generateNextCode(department = 'Ayurvedic', patientType = 'OPD') {
    const isAyu = department.toLowerCase().includes('ayu');
    const isPT = department.toLowerCase().includes('physio') || department.toLowerCase() === 'pt';
    const deptTag = isAyu ? 'AYU' : (isPT ? 'PT' : 'GEN');

    // Count how many patients registered under this department
    const countSql = `
      SELECT COUNT(*) as count 
      FROM patients 
      WHERE UPPER(department) = $1 AND UPPER(patient_type) = $2
    `;
    const countRes = await db.query(countSql, [department.toUpperCase(), patientType.toUpperCase()]);
    const nextSeq = (countRes[0]?.count || 0) + 1;

    if (patientType.toUpperCase() === 'INDOOR') {
      return `0-${nextSeq}-${deptTag}(IPD)`;
    } else {
      // OPD format: 0-1-AYU, 0-2-AYU, 0-1-PT, etc.
      return `0-${nextSeq}-${deptTag}`;
    }
  }

  async getAllPatients(search = '', department = '', patientType = '', status = 'all') {
    let sql = 'SELECT * FROM patients WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (search) {
      sql += ` AND (name LIKE $${paramIndex} OR patient_code LIKE $${paramIndex} OR phone LIKE $${paramIndex} OR doctor_name LIKE $${paramIndex} OR diagnosis LIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    if (department && department !== 'all') {
      sql += ` AND department = $${paramIndex}`;
      params.push(department);
      paramIndex++;
    }

    if (patientType && patientType !== 'all') {
      sql += ` AND patient_type = $${paramIndex}`;
      params.push(patientType);
      paramIndex++;
    }

    if (status && status !== 'all') {
      sql += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    sql += ' ORDER BY id DESC';
    return await db.query(sql, params);
  }

  async getOpdList(search = '', department = '') {
    return await this.getAllPatients(search, department, 'OPD', 'all');
  }

  async getIndoorList(search = '', department = '') {
    return await this.getAllPatients(search, department, 'Indoor', 'all');
  }

  async getPatientById(id) {
    const rows = await db.query('SELECT * FROM patients WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async createPatient(data) {
    const {
      name,
      phone,
      email = '',
      age,
      weight,
      gender,
      date_of_birth = null,
      department = 'Ayurvedic',
      patient_type = 'OPD',
      ward_bed_no = '',
      doctor_name = '',
      blood_group = '',
      address = '',
      chief_complaint = '',
      diagnosis = '',
      status = 'Active'
    } = data;

    // Strict Validations according to requirements
    if (!name || !name.trim()) {
      throw new Error('Patient full name is compulsory.');
    }
    if (!phone || !phone.trim()) {
      throw new Error('Phone number is compulsory.');
    }
    if (age === undefined || age === null || age === '' || isNaN(age) || Number(age) <= 0) {
      throw new Error('Valid age is compulsory.');
    }
    if (weight === undefined || weight === null || weight === '' || isNaN(weight) || Number(weight) <= 0) {
      throw new Error('Valid weight is compulsory.');
    }
    if (!gender || !gender.trim()) {
      throw new Error('Gender is compulsory.');
    }

    // Determine or generate patient code
    let finalCode = data.patient_code ? data.patient_code.trim().toUpperCase() : '';
    if (!finalCode) {
      finalCode = await this.generateNextCode(department, patient_type);
    }

    // Check duplicate code
    const existing = await db.query('SELECT id FROM patients WHERE patient_code = $1', [finalCode]);
    if (existing.length > 0) {
      // If code already taken, regenerate with higher increment
      const countRes = await db.query('SELECT COUNT(*) as count FROM patients');
      const suffix = (countRes[0]?.count || 0) + 1;
      const deptTag = department.toLowerCase().includes('ayu') ? 'AYU' : 'PT';
      finalCode = `0-${suffix}-${deptTag}`;
    }

    const admissionDate = (patient_type === 'Indoor') ? (data.admission_date || new Date().toISOString()) : null;

    const insertSql = `
      INSERT INTO patients (
        patient_code, name, phone, email, age, weight, gender, date_of_birth,
        department, patient_type, ward_bed_no, admission_date, doctor_name,
        blood_group, address, chief_complaint, diagnosis, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
    `;

    await db.query(insertSql, [
      finalCode,
      name.trim(),
      phone.trim(),
      email ? email.trim() : '',
      parseInt(age, 10),
      parseFloat(weight),
      gender,
      date_of_birth || null,
      department,
      patient_type,
      ward_bed_no || '',
      admissionDate,
      doctor_name || '',
      blood_group || '',
      address || '',
      chief_complaint || '',
      diagnosis || '',
      status || (patient_type === 'Indoor' ? 'Admitted' : 'Active')
    ]);

    // If auto_appointment flag is provided, create an appointment token
    if (data.create_appointment || patient_type === 'OPD') {
      const todayStr = new Date().toISOString().split('T')[0];
      const tokenCount = await db.query(
        'SELECT COUNT(*) as count FROM appointments WHERE appointment_date = $1 AND department = $2',
        [todayStr, department]
      );
      const tokenNum = (tokenCount[0]?.count || 0) + 1;

      await db.query(
        `INSERT INTO appointments (patient_code, patient_name, department, doctor_name, appointment_date, appointment_time, token_number, reason, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          finalCode,
          name.trim(),
          department,
          doctor_name || (department.toLowerCase().includes('ayu') ? 'Dr. H. N. Patel' : 'Dr. Priya Desai (PT)'),
          todayStr,
          new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          tokenNum,
          chief_complaint || 'OPD Consultation',
          'Scheduled'
        ]
      );
    }

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['REGISTER_PATIENT', `Registered ${patient_type} patient: ${name} (${finalCode}) in ${department} dept.`]
    );

    const rows = await db.query('SELECT * FROM patients WHERE patient_code = $1', [finalCode]);
    return rows[0];
  }

  async updatePatient(id, data) {
    const existing = await this.getPatientById(id);
    if (!existing) {
      throw new Error('Patient record not found.');
    }

    const {
      name,
      phone,
      email,
      age,
      weight,
      gender,
      date_of_birth,
      department,
      patient_type,
      ward_bed_no,
      doctor_name,
      blood_group,
      address,
      chief_complaint,
      diagnosis,
      status
    } = data;

    await db.query(
      `UPDATE patients SET
        name = $1, phone = $2, email = $3, age = $4, weight = $5, gender = $6,
        date_of_birth = $7, department = $8, patient_type = $9, ward_bed_no = $10,
        doctor_name = $11, blood_group = $12, address = $13, chief_complaint = $14,
        diagnosis = $15, status = $16, updated_at = CURRENT_TIMESTAMP
       WHERE id = $17`,
      [
        name !== undefined ? name : existing.name,
        phone !== undefined ? phone : existing.phone,
        email !== undefined ? email : existing.email,
        age !== undefined ? parseInt(age, 10) : existing.age,
        weight !== undefined ? parseFloat(weight) : existing.weight,
        gender !== undefined ? gender : existing.gender,
        date_of_birth !== undefined ? date_of_birth : existing.date_of_birth,
        department !== undefined ? department : existing.department,
        patient_type !== undefined ? patient_type : existing.patient_type,
        ward_bed_no !== undefined ? ward_bed_no : existing.ward_bed_no,
        doctor_name !== undefined ? doctor_name : existing.doctor_name,
        blood_group !== undefined ? blood_group : existing.blood_group,
        address !== undefined ? address : existing.address,
        chief_complaint !== undefined ? chief_complaint : existing.chief_complaint,
        diagnosis !== undefined ? diagnosis : existing.diagnosis,
        status !== undefined ? status : existing.status,
        id
      ]
    );

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['UPDATE_PATIENT', `Updated patient info for: ${name || existing.name} (${existing.patient_code})`]
    );

    return await this.getPatientById(id);
  }

  async deletePatient(id) {
    const existing = await this.getPatientById(id);
    if (!existing) {
      throw new Error('Patient not found.');
    }

    await db.query('DELETE FROM appointments WHERE patient_code = $1', [existing.patient_code]);
    await db.query('DELETE FROM patients WHERE id = $1', [id]);

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['DELETE_PATIENT', `Deleted patient record: ${existing.name} (${existing.patient_code})`]
    );

    return true;
  }
}

module.exports = new PatientService();
