const db = require('../../config/database');

async function generateReceiptNo() {
  const year = new Date().getFullYear();
  const rows = await db.query(
    `SELECT receipt_no FROM payments WHERE receipt_no LIKE $1 ORDER BY id DESC LIMIT 1`,
    [`REC-${year}-%`]
  );
  if (!rows.length) return `REC-${year}-0001`;
  const lastNum = parseInt(rows[0].receipt_no.split('-')[2], 10) || 0;
  return `REC-${year}-${String(lastNum + 1).padStart(4, '0')}`;
}

async function getAllPayments(search = '', status = '') {
  let query = 'SELECT * FROM payments WHERE 1=1';
  const params = [];

  if (search) {
    params.push(`%${search}%`);
    query += ` AND (receipt_no LIKE $${params.length} OR patient_name LIKE $${params.length} OR payment_mode LIKE $${params.length} OR payment_for LIKE $${params.length})`;
  }

  if (status && status !== 'all') {
    params.push(status);
    query += ` AND status = $${params.length}`;
  }

  query += ' ORDER BY id DESC';
  return await db.query(query, params);
}

async function getPaymentById(id) {
  const rows = await db.query('SELECT * FROM payments WHERE id = $1', [id]);
  return rows[0] || null;
}

async function getPaymentSummary() {
  const summary = await db.query(`
    SELECT
      COUNT(*) as total_transactions,
      COALESCE(SUM(CASE WHEN status = 'Paid' THEN amount ELSE 0 END), 0) as total_collected,
      COALESCE(SUM(CASE WHEN status = 'Pending' THEN amount ELSE 0 END), 0) as total_pending,
      COALESCE(SUM(CASE WHEN payment_date = date('now') AND status = 'Paid' THEN amount ELSE 0 END), 0) as today_collection
    FROM payments
  `);
  return summary[0] || { total_transactions: 0, total_collected: 0, total_pending: 0, today_collection: 0 };
}

async function createPayment(data) {
  const {
    patient_id,
    patient_code,
    patient_name,
    payment_date,
    amount,
    payment_mode,
    payment_for,
    status,
    notes
  } = data;

  if (!patient_name || amount === undefined || amount === null) {
    throw new Error('Patient Name and Valid Amount are compulsory');
  }

  const receipt_no = data.receipt_no || await generateReceiptNo();

  const res = await db.query(
    `INSERT INTO payments (
       receipt_no, patient_id, patient_code, patient_name, payment_date,
       amount, payment_mode, payment_for, status, notes
     ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
    [
      receipt_no,
      patient_id || null,
      patient_code || null,
      patient_name,
      payment_date || new Date().toISOString().split('T')[0],
      amount,
      payment_mode || 'Cash',
      payment_for || 'Consultation',
      status || 'Paid',
      notes || ''
    ]
  );
  return await getPaymentById(res[0]?.id);
}

async function updatePayment(id, data) {
  const existing = await getPaymentById(id);
  if (!existing) throw new Error('Payment not found');

  const {
    patient_name,
    payment_date,
    amount,
    payment_mode,
    payment_for,
    status,
    notes
  } = data;

  await db.query(
    `UPDATE payments
     SET patient_name = $1, payment_date = $2, amount = $3, payment_mode = $4,
         payment_for = $5, status = $6, notes = $7, updated_at = CURRENT_TIMESTAMP
     WHERE id = $8`,
    [
      patient_name !== undefined ? patient_name : existing.patient_name,
      payment_date !== undefined ? payment_date : existing.payment_date,
      amount !== undefined ? amount : existing.amount,
      payment_mode !== undefined ? payment_mode : existing.payment_mode,
      payment_for !== undefined ? payment_for : existing.payment_for,
      status !== undefined ? status : existing.status,
      notes !== undefined ? notes : existing.notes,
      id
    ]
  );
  return await getPaymentById(id);
}

async function deletePayment(id) {
  const existing = await getPaymentById(id);
  if (!existing) throw new Error('Payment not found');

  await db.query('DELETE FROM payments WHERE id = $1', [id]);
  return true;
}

module.exports = {
  generateReceiptNo,
  getAllPayments,
  getPaymentById,
  getPaymentSummary,
  createPayment,
  updatePayment,
  deletePayment
};
