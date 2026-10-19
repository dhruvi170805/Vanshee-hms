const db = require('../../config/database');

class SupplierService {
  async getAllSuppliers(search = '', status = 'all') {
    let sql = 'SELECT * FROM medicine_suppliers WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (search) {
      sql += ` AND (name LIKE $${paramIndex} OR code LIKE $${paramIndex} OR contact_person LIKE $${paramIndex} OR phone LIKE $${paramIndex} OR city LIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    if (status === 'active') {
      sql += ` AND is_active = 1`;
    } else if (status === 'inactive') {
      sql += ` AND is_active = 0`;
    }

    sql += ' ORDER BY id DESC';
    return await db.query(sql, params);
  }

  async getSupplierById(id) {
    const rows = await db.query('SELECT * FROM medicine_suppliers WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async createSupplier(data) {
    const { code, name, contact_person, phone, email, address, city, gstin, dl_number, is_active = 1 } = data;

    if (!phone) {
      throw new Error('Phone number is compulsory for supplier registration.');
    }

    let finalCode = code ? code.trim().toUpperCase() : '';
    if (!finalCode) {
      // Auto generate code
      const countRes = await db.query('SELECT COUNT(*) as count FROM medicine_suppliers');
      const nextNum = (countRes[0]?.count || 0) + 1;
      finalCode = `SUP-${String(nextNum).padStart(3, '0')}`;
    }

    // Check duplicate code
    const existing = await db.query('SELECT id FROM medicine_suppliers WHERE code = $1', [finalCode]);
    if (existing.length > 0) {
      throw new Error(`Supplier code '${finalCode}' already exists.`);
    }

    await db.query(
      `INSERT INTO medicine_suppliers (code, name, contact_person, phone, email, address, city, gstin, dl_number, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [finalCode, name, contact_person || '', phone, email || '', address || '', city || '', gstin || '', dl_number || '', is_active ? 1 : 0]
    );

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['CREATE_SUPPLIER', `Created medicine supplier: ${name} (${finalCode})`]
    );

    const rows = await db.query('SELECT * FROM medicine_suppliers WHERE code = $1', [finalCode]);
    return rows[0];
  }

  async updateSupplier(id, data) {
    const { code, name, contact_person, phone, email, address, city, gstin, dl_number, is_active } = data;
    const existing = await this.getSupplierById(id);
    if (!existing) {
      throw new Error('Supplier record not found.');
    }

    let finalCode = code ? code.trim().toUpperCase() : existing.code;
    if (finalCode !== existing.code) {
      const duplicate = await db.query('SELECT id FROM medicine_suppliers WHERE code = $1 AND id != $2', [finalCode, id]);
      if (duplicate.length > 0) {
        throw new Error(`Supplier code '${finalCode}' is already in use.`);
      }
    }

    await db.query(
      `UPDATE medicine_suppliers 
       SET code = $1, name = $2, contact_person = $3, phone = $4, email = $5, address = $6, city = $7, gstin = $8, dl_number = $9, is_active = $10, updated_at = CURRENT_TIMESTAMP
       WHERE id = $11`,
      [
        finalCode,
        name !== undefined ? name : existing.name,
        contact_person !== undefined ? contact_person : existing.contact_person,
        phone !== undefined ? phone : existing.phone,
        email !== undefined ? email : existing.email,
        address !== undefined ? address : existing.address,
        city !== undefined ? city : existing.city,
        gstin !== undefined ? gstin : existing.gstin,
        dl_number !== undefined ? dl_number : existing.dl_number,
        is_active !== undefined ? (is_active ? 1 : 0) : existing.is_active,
        id
      ]
    );

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['UPDATE_SUPPLIER', `Updated supplier: ${name || existing.name} (${finalCode})`]
    );

    return await this.getSupplierById(id);
  }

  async deleteSupplier(id) {
    const existing = await this.getSupplierById(id);
    if (!existing) {
      throw new Error('Supplier not found.');
    }

    // Check if supplier has purchases
    const purchases = await db.query('SELECT COUNT(*) as count FROM purchases WHERE supplier_id = $1', [id]);
    if ((purchases[0]?.count || 0) > 0) {
      throw new Error('Cannot delete supplier with linked purchase invoices. Deactivate instead.');
    }

    await db.query('DELETE FROM medicine_suppliers WHERE id = $1', [id]);
    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['DELETE_SUPPLIER', `Deleted supplier: ${existing.name} (${existing.code})`]
    );
    return true;
  }
}

module.exports = new SupplierService();
