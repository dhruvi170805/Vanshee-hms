const db = require('../../config/database');

async function generateReportNo() {
  const year = new Date().getFullYear();
  const rows = await db.query(
    `SELECT report_no FROM lab_reports WHERE report_no LIKE $1 ORDER BY id DESC LIMIT 1`,
    [`LAB-${year}-%`]
  );
  if (!rows.length) return `LAB-${year}-0001`;
  const lastNum = parseInt(rows[0].report_no.split('-')[2], 10) || 0;
  return `LAB-${year}-${String(lastNum + 1).padStart(4, '0')}`;
}

async function getAllReports(search = '', status = '') {
  let query = 'SELECT * FROM lab_reports WHERE 1=1';
  const params = [];

  if (search) {
    params.push(`%${search}%`);
    query += ` AND (report_no LIKE $${params.length} OR patient_name LIKE $${params.length} OR test_name LIKE $${params.length} OR doctor_name LIKE $${params.length})`;
  }

  if (status && status !== 'all') {
    params.push(status);
    query += ` AND status = $${params.length}`;
  }

  query += ' ORDER BY id DESC';
  return await db.query(query, params);
}

async function getReportById(id) {
  const rows = await db.query('SELECT * FROM lab_reports WHERE id = $1', [id]);
  return rows[0] || null;
}

async function createReport(data) {
  const {
    patient_id,
    patient_code,
    patient_name,
    test_name,
    test_category,
    doctor_name,
    sample_collected_at,
    report_date,
    result_value,
    normal_range,
    unit,
    status,
    remarks,
    charge
  } = data;

  if (!test_name || !patient_name) {
    throw new Error('Test Name and Patient Name are required');
  }

  const report_no = data.report_no || await generateReportNo();

  const res = await db.query(
    `INSERT INTO lab_reports (
       report_no, patient_id, patient_code, patient_name, test_name, test_category,
       doctor_name, sample_collected_at, report_date, result_value, normal_range,
       unit, status, remarks, charge
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)`,
    [
      report_no,
      patient_id || null,
      patient_code || null,
      patient_name,
      test_name,
      test_category || 'General',
      doctor_name || 'Attending Physician',
      sample_collected_at || new Date().toISOString(),
      report_date || new Date().toISOString().split('T')[0],
      result_value || '',
      normal_range || '',
      unit || '',
      status || 'Pending',
      remarks || '',
      charge || 0
    ]
  );
  return await getReportById(res[0]?.id);
}

async function updateReport(id, data) {
  const existing = await getReportById(id);
  if (!existing) throw new Error('Lab Report not found');

  const {
    patient_name,
    test_name,
    test_category,
    doctor_name,
    report_date,
    result_value,
    normal_range,
    unit,
    status,
    remarks,
    charge
  } = data;

  await db.query(
    `UPDATE lab_reports
     SET patient_name = $1, test_name = $2, test_category = $3, doctor_name = $4,
         report_date = $5, result_value = $6, normal_range = $7, unit = $8,
         status = $9, remarks = $10, charge = $11, updated_at = CURRENT_TIMESTAMP
     WHERE id = $12`,
    [
      patient_name !== undefined ? patient_name : existing.patient_name,
      test_name !== undefined ? test_name : existing.test_name,
      test_category !== undefined ? test_category : existing.test_category,
      doctor_name !== undefined ? doctor_name : existing.doctor_name,
      report_date !== undefined ? report_date : existing.report_date,
      result_value !== undefined ? result_value : existing.result_value,
      normal_range !== undefined ? normal_range : existing.normal_range,
      unit !== undefined ? unit : existing.unit,
      status !== undefined ? status : existing.status,
      remarks !== undefined ? remarks : existing.remarks,
      charge !== undefined ? charge : existing.charge,
      id
    ]
  );
  return await getReportById(id);
}

async function deleteReport(id) {
  const existing = await getReportById(id);
  if (!existing) throw new Error('Lab Report not found');

  await db.query('DELETE FROM lab_reports WHERE id = $1', [id]);
  return true;
}

module.exports = {
  generateReportNo,
  getAllReports,
  getReportById,
  createReport,
  updateReport,
  deleteReport
};
