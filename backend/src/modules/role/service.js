const db = require('../../config/database');

async function getAllRoles() {
  return await db.query('SELECT * FROM roles ORDER BY id ASC');
}

async function getRoleById(id) {
  const rows = await db.query('SELECT * FROM roles WHERE id = $1', [id]);
  return rows[0] || null;
}

async function createRole(data) {
  const { role_code, role_name, description, is_active } = data;
  if (!role_code || !role_name) {
    throw new Error('Role Code and Role Name are required');
  }

  const existing = await db.query('SELECT id FROM roles WHERE role_code = $1', [role_code]);
  if (existing.length > 0) {
    throw new Error(`Role Code "${role_code}" already exists`);
  }

  const res = await db.query(
    `INSERT INTO roles (role_code, role_name, description, is_active)
     VALUES ($1, $2, $3, $4)`,
    [role_code.toUpperCase(), role_name, description || '', is_active !== undefined ? is_active : 1]
  );
  return await getRoleById(res[0]?.id);
}

async function updateRole(id, data) {
  const existing = await getRoleById(id);
  if (!existing) throw new Error('Role not found');

  const { role_name, description, is_active } = data;

  await db.query(
    `UPDATE roles
     SET role_name = $1, description = $2, is_active = $3
     WHERE id = $4`,
    [
      role_name !== undefined ? role_name : existing.role_name,
      description !== undefined ? description : existing.description,
      is_active !== undefined ? is_active : existing.is_active,
      id
    ]
  );
  return await getRoleById(id);
}

async function deleteRole(id) {
  const existing = await getRoleById(id);
  if (!existing) throw new Error('Role not found');

  // Check if any users are assigned
  const assigned = await db.query('SELECT id FROM users WHERE role_id = $1 AND is_active = 1', [id]);
  if (assigned.length > 0) {
    throw new Error('Cannot delete role: active users are assigned to this role');
  }

  await db.query('DELETE FROM roles WHERE id = $1', [id]);
  return true;
}

module.exports = {
  getAllRoles,
  getRoleById,
  createRole,
  updateRole,
  deleteRole
};
