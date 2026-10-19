const db = require('../../config/database');

class MedicineService {
  async getAllMedicines(params = {}) {
    const { search = '', classification_id = '', stock_filter = 'all', status = 'all' } = params;

    let sql = `
      SELECT m.*, c.name as classification_name, c.code as classification_code 
      FROM medicines m
      LEFT JOIN medicine_classifications c ON m.classification_id = c.id
      WHERE 1=1
    `;
    const queryParams = [];
    let pIdx = 1;

    if (search) {
      sql += ` AND (m.name LIKE $${pIdx} OR m.generic_name LIKE $${pIdx} OR m.sku_code LIKE $${pIdx} OR m.manufacturer LIKE $${pIdx})`;
      queryParams.push(`%${search}%`);
      pIdx++;
    }

    if (classification_id) {
      sql += ` AND m.classification_id = $${pIdx}`;
      queryParams.push(classification_id);
      pIdx++;
    }

    if (stock_filter === 'low') {
      sql += ` AND m.stock_quantity <= m.reorder_level AND m.stock_quantity > 0`;
    } else if (stock_filter === 'out_of_stock') {
      sql += ` AND m.stock_quantity = 0`;
    } else if (stock_filter === 'alert') {
      sql += ` AND m.stock_quantity <= m.reorder_level`;
    }

    if (status === 'active') {
      sql += ` AND m.is_active = 1`;
    } else if (status === 'inactive') {
      sql += ` AND m.is_active = 0`;
    }

    sql += ' ORDER BY m.id DESC';
    return await db.query(sql, queryParams);
  }

  async getMedicineById(id) {
    const sql = `
      SELECT m.*, c.name as classification_name, c.code as classification_code 
      FROM medicines m
      LEFT JOIN medicine_classifications c ON m.classification_id = c.id
      WHERE m.id = $1
    `;
    const rows = await db.query(sql, [id]);
    return rows[0] || null;
  }

  async createMedicine(data) {
    const {
      classification_id,
      name,
      generic_name = '',
      sku_code,
      manufacturer = '',
      unit = 'Tablet',
      dosage_strength = '',
      price = 0,
      stock_quantity = 0,
      reorder_level = 10,
      is_active = 1
    } = data;

    // Verify classification exists
    const classRows = await db.query('SELECT id, name FROM medicine_classifications WHERE id = $1', [classification_id]);
    if (classRows.length === 0) {
      throw new Error(`Classification with ID ${classification_id} does not exist.`);
    }

    // Check duplicate SKU
    const existingSku = await db.query('SELECT id FROM medicines WHERE sku_code = $1', [sku_code.toUpperCase()]);
    if (existingSku.length > 0) {
      throw new Error(`Medicine SKU code '${sku_code.toUpperCase()}' already exists.`);
    }

    await db.query(
      `INSERT INTO medicines (classification_id, name, generic_name, sku_code, manufacturer, unit, dosage_strength, price, stock_quantity, reorder_level, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
      [classification_id, name, generic_name, sku_code.toUpperCase(), manufacturer, unit, dosage_strength, price, stock_quantity, reorder_level, is_active]
    );

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['CREATE_MEDICINE', `Added medicine '${name}' (${sku_code.toUpperCase()}) with stock ${stock_quantity}`]
    );

    const rows = await db.query('SELECT * FROM medicines WHERE sku_code = $1', [sku_code.toUpperCase()]);
    return rows[0];
  }

  async updateMedicine(id, data) {
    const existing = await this.getMedicineById(id);
    if (!existing) {
      throw new Error('Medicine not found.');
    }

    const {
      classification_id,
      name,
      generic_name,
      sku_code,
      manufacturer,
      unit,
      dosage_strength,
      price,
      stock_quantity,
      reorder_level,
      is_active
    } = data;

    if (classification_id && classification_id !== existing.classification_id) {
      const classRows = await db.query('SELECT id FROM medicine_classifications WHERE id = $1', [classification_id]);
      if (classRows.length === 0) {
        throw new Error(`Classification with ID ${classification_id} does not exist.`);
      }
    }

    if (sku_code && sku_code.toUpperCase() !== existing.sku_code) {
      const dup = await db.query('SELECT id FROM medicines WHERE sku_code = $1 AND id != $2', [sku_code.toUpperCase(), id]);
      if (dup.length > 0) {
        throw new Error(`SKU code '${sku_code.toUpperCase()}' already in use.`);
      }
    }

    const newClassId = classification_id !== undefined ? classification_id : existing.classification_id;
    const newName = name !== undefined ? name : existing.name;
    const newGenName = generic_name !== undefined ? generic_name : existing.generic_name;
    const newSku = sku_code ? sku_code.toUpperCase() : existing.sku_code;
    const newMfg = manufacturer !== undefined ? manufacturer : existing.manufacturer;
    const newUnit = unit !== undefined ? unit : existing.unit;
    const newDosage = dosage_strength !== undefined ? dosage_strength : existing.dosage_strength;
    const newPrice = price !== undefined ? price : existing.price;
    const newStock = stock_quantity !== undefined ? stock_quantity : existing.stock_quantity;
    const newReorder = reorder_level !== undefined ? reorder_level : existing.reorder_level;
    const newStatus = is_active !== undefined ? is_active : existing.is_active;

    await db.query(
      `UPDATE medicines SET classification_id = $1, name = $2, generic_name = $3, sku_code = $4, manufacturer = $5, unit = $6, dosage_strength = $7, price = $8, stock_quantity = $9, reorder_level = $10, is_active = $11, updated_at = CURRENT_TIMESTAMP WHERE id = $12`,
      [newClassId, newName, newGenName, newSku, newMfg, newUnit, newDosage, newPrice, newStock, newReorder, newStatus, id]
    );

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['UPDATE_MEDICINE', `Updated medicine ID ${id}: ${newName} (Stock: ${newStock})`]
    );

    return await this.getMedicineById(id);
  }

  async deleteMedicine(id) {
    const existing = await this.getMedicineById(id);
    if (!existing) {
      throw new Error('Medicine not found.');
    }

    await db.query('DELETE FROM medicines WHERE id = $1', [id]);

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['DELETE_MEDICINE', `Deleted medicine: ${existing.name} (${existing.sku_code})`]
    );

    return true;
  }
}

module.exports = new MedicineService();
