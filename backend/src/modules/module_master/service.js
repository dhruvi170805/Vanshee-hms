const db = require('../../config/database');

async function getAllModules(search = '', category = '') {
  let query = 'SELECT * FROM system_modules WHERE 1=1';
  const params = [];

  if (search) {
    params.push(`%${search}%`);
    query += ` AND (module_name LIKE $${params.length} OR module_key LIKE $${params.length} OR description LIKE $${params.length})`;
  }

  if (category && category !== 'all') {
    params.push(category);
    query += ` AND category = $${params.length}`;
  }

  query += ' ORDER BY id ASC';
  return await db.query(query, params);
}

async function getModuleById(id) {
  const rows = await db.query('SELECT * FROM system_modules WHERE id = $1', [id]);
  return rows[0] || null;
}

async function createModule(data) {
  const { module_key, module_name, category, description, is_active } = data;
  if (!module_key || !module_name || !category) {
    throw new Error('Module Key, Module Name, and Category are required');
  }

  const existing = await db.query('SELECT id FROM system_modules WHERE module_key = $1', [module_key]);
  if (existing.length > 0) {
    throw new Error(`Module with key "${module_key}" already exists`);
  }

  const res = await db.query(
    `INSERT INTO system_modules (module_key, module_name, category, description, is_active)
     VALUES ($1, $2, $3, $4, $5)`,
    [module_key, module_name, category, description || '', is_active !== undefined ? is_active : 1]
  );
  const newId = res[0]?.id;
  return await getModuleById(newId);
}

async function updateModule(id, data) {
  const existing = await getModuleById(id);
  if (!existing) throw new Error('Module not found');

  const { module_name, category, description, is_active } = data;

  await db.query(
    `UPDATE system_modules
     SET module_name = $1, category = $2, description = $3, is_active = $4
     WHERE id = $5`,
    [
      module_name !== undefined ? module_name : existing.module_name,
      category !== undefined ? category : existing.category,
      description !== undefined ? description : existing.description,
      is_active !== undefined ? is_active : existing.is_active,
      id
    ]
  );

  return await getModuleById(id);
}

async function deleteModule(id) {
  const existing = await getModuleById(id);
  if (!existing) throw new Error('Module not found');

  await db.query('DELETE FROM system_modules WHERE id = $1', [id]);
  return true;
}

// Role Permissions
async function getRolePermissions(roleId) {
  // Get all active modules joined with role permissions for this role
  const sql = `
    SELECT sm.id as module_id, sm.module_key, sm.module_name, sm.category, sm.description,
           COALESCE(rp.can_view, 0) as can_view,
           COALESCE(rp.can_create, 0) as can_create,
           COALESCE(rp.can_edit, 0) as can_edit,
           COALESCE(rp.can_delete, 0) as can_delete
    FROM system_modules sm
    LEFT JOIN role_permissions rp ON sm.module_key = rp.module_key AND rp.role_id = $1
    WHERE sm.is_active = 1
    ORDER BY sm.id ASC
  `;
  return await db.query(sql, [roleId]);
}

async function saveRolePermissions(roleId, permissions) {
  // permissions: array of { module_key, can_view, can_create, can_edit, can_delete }
  // Delete existing role permissions for this role
  await db.query('DELETE FROM role_permissions WHERE role_id = $1', [roleId]);

  for (const p of permissions) {
    await db.query(
      `INSERT INTO role_permissions (role_id, module_key, can_view, can_create, can_edit, can_delete)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [
        roleId,
        p.module_key,
        p.can_view ? 1 : 0,
        p.can_create ? 1 : 0,
        p.can_edit ? 1 : 0,
        p.can_delete ? 1 : 0
      ]
    );
  }
  return await getRolePermissions(roleId);
}

module.exports = {
  getAllModules,
  getModuleById,
  createModule,
  updateModule,
  deleteModule,
  getRolePermissions,
  saveRolePermissions
};
