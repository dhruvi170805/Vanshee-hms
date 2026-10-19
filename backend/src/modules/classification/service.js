const db = require('../../config/database');

class ClassificationService {
  async getAllClassifications(search = '', status = 'all') {
    let sql = 'SELECT * FROM medicine_classifications WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (search) {
      sql += ` AND (name LIKE $${paramIndex} OR code LIKE $${paramIndex} OR description LIKE $${paramIndex})`;
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

  async getClassificationById(id) {
    const rows = await db.query('SELECT * FROM medicine_classifications WHERE id = $1', [id]);
    return rows[0] || null;
  }

  async createClassification(data) {
    const { code, name, description, is_active = 1 } = data;

    // Check duplicate code
    const existing = await db.query('SELECT id FROM medicine_classifications WHERE code = $1', [code.toUpperCase()]);
    if (existing.length > 0) {
      throw new Error(`Classification code '${code.toUpperCase()}' already exists.`);
    }

    await db.query(
      `INSERT INTO medicine_classifications (code, name, description, is_active) VALUES ($1, $2, $3, $4)`,
      [code.toUpperCase(), name, description, is_active]
    );

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['CREATE_CLASSIFICATION', `Created medicine classification: ${name} (${code.toUpperCase()})`]
    );

    const rows = await db.query('SELECT * FROM medicine_classifications WHERE code = $1', [code.toUpperCase()]);
    return rows[0];
  }

  async updateClassification(id, data) {
    const { code, name, description, is_active } = data;
    const existing = await this.getClassificationById(id);
    if (!existing) {
      throw new Error('Classification not found.');
    }

    if (code && code.toUpperCase() !== existing.code) {
      const dup = await db.query('SELECT id FROM medicine_classifications WHERE code = $1 AND id != $2', [code.toUpperCase(), id]);
      if (dup.length > 0) {
        throw new Error(`Classification code '${code.toUpperCase()}' already in use.`);
      }
    }

    const newCode = code ? code.toUpperCase() : existing.code;
    const newName = name !== undefined ? name : existing.name;
    const newDesc = description !== undefined ? description : existing.description;
    const newStatus = is_active !== undefined ? is_active : existing.is_active;

    await db.query(
      `UPDATE medicine_classifications SET code = $1, name = $2, description = $3, is_active = $4, updated_at = CURRENT_TIMESTAMP WHERE id = $5`,
      [newCode, newName, newDesc, newStatus, id]
    );

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['UPDATE_CLASSIFICATION', `Updated medicine classification ID ${id}: ${newName}`]
    );

    return await this.getClassificationById(id);
  }

  async deleteClassification(id) {
    const existing = await this.getClassificationById(id);
    if (!existing) {
      throw new Error('Classification not found.');
    }

    // Check tied medicines
    const medicines = await db.query('SELECT COUNT(*) as count FROM medicines WHERE classification_id = $1', [id]);
    const medCount = medicines[0]?.count || 0;
    if (medCount > 0) {
      throw new Error(`Cannot delete classification '${existing.name}' because it contains ${medCount} medicine(s). Delete or reassign those medicines first.`);
    }

    await db.query('DELETE FROM medicine_classifications WHERE id = $1', [id]);

    await db.query(
      `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
      ['DELETE_CLASSIFICATION', `Deleted classification: ${existing.name} (${existing.code})`]
    );

    return true;
  }
}

module.exports = new ClassificationService();
