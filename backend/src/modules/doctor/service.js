const db = require('../../config/database');

async function generateDoctorCode() {
  const rows = await db.query('SELECT doctor_code FROM doctors ORDER BY id DESC LIMIT 1');
  if (!rows.length || !rows[0].doctor_code) return 'DR-001';
  const lastCode = rows[0].doctor_code; // e.g. DR-004
  const numPart = parseInt(lastCode.replace(/[^0-9]/g, ''), 10) || 0;
  const nextNum = numPart + 1;
  return `DR-${String(nextNum).padStart(3, '0')}`;
}

async function getAllDoctors(search = '', department = '') {
  let query = 'SELECT * FROM doctors WHERE is_active = 1';
  const params = [];

  if (search) {
    params.push(`%${search}%`);
    query += ` AND (full_name LIKE $${params.length} OR doctor_code LIKE $${params.length} OR specialty LIKE $${params.length} OR phone LIKE $${params.length})`;
  }

  if (department && department !== 'all') {
    params.push(department);
    query += ` AND department = $${params.length}`;
  }

  query += ' ORDER BY id ASC';
  return await db.query(query, params);
}

async function getDoctorById(id) {
  const rows = await db.query('SELECT * FROM doctors WHERE id = $1', [id]);
  return rows[0] || null;
}

async function createDoctor(data) {
  const { full_name, specialty, department, phone, email, qualification, experience_years, consultation_fee } = data;
  if (!full_name) throw new Error('Doctor Full Name is compulsory');

  const doctor_code = data.doctor_code || await generateDoctorCode();

  const res = await db.query(
    `INSERT INTO doctors (doctor_code, full_name, specialty, department, phone, email, qualification, experience_years, consultation_fee, is_active)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 1)`,
    [
      doctor_code,
      full_name,
      specialty || null,
      department || 'General',
      phone || null,
      email || null,
      qualification || null,
      experience_years || 0,
      consultation_fee || 0
    ]
  );
  return await getDoctorById(res[0]?.id);
}

async function updateDoctor(id, data) {
  const existing = await getDoctorById(id);
  if (!existing) throw new Error('Doctor not found');

  const { full_name, specialty, department, phone, email, qualification, experience_years, consultation_fee, is_active } = data;

  await db.query(
    `UPDATE doctors
     SET full_name = $1, specialty = $2, department = $3, phone = $4, email = $5,
         qualification = $6, experience_years = $7, consultation_fee = $8, is_active = $9,
         updated_at = CURRENT_TIMESTAMP
     WHERE id = $10`,
    [
      full_name !== undefined ? full_name : existing.full_name,
      specialty !== undefined ? specialty : existing.specialty,
      department !== undefined ? department : existing.department,
      phone !== undefined ? phone : existing.phone,
      email !== undefined ? email : existing.email,
      qualification !== undefined ? qualification : existing.qualification,
      experience_years !== undefined ? experience_years : existing.experience_years,
      consultation_fee !== undefined ? consultation_fee : existing.consultation_fee,
      is_active !== undefined ? is_active : existing.is_active,
      id
    ]
  );
  return await getDoctorById(id);
}

async function deleteDoctor(id) {
  const existing = await getDoctorById(id);
  if (!existing) throw new Error('Doctor not found');

  await db.query('UPDATE doctors SET is_active = 0 WHERE id = $1', [id]);
  return true;
}

module.exports = {
  generateDoctorCode,
  getAllDoctors,
  getDoctorById,
  createDoctor,
  updateDoctor,
  deleteDoctor
};
