const db = require('../../config/database');

async function getAllUsers(search = '') {
  let sql = `
    SELECT u.id, u.username, u.full_name, u.email, u.phone, u.role_id, u.is_active, u.created_at,
           r.role_name, r.role_code
    FROM users u
    LEFT JOIN roles r ON u.role_id = r.id
    WHERE 1=1
  `;
  const params = [];
  if (search) {
    params.push(`%${search}%`);
    sql += ` AND (u.username LIKE $${params.length} OR u.full_name LIKE $${params.length} OR u.email LIKE $${params.length})`;
  }
  sql += ' ORDER BY u.id DESC';
  return await db.query(sql, params);
}

async function getUserById(id) {
  const rows = await db.query(
    `SELECT u.id, u.username, u.full_name, u.email, u.phone, u.role_id, u.is_active, u.created_at,
            r.role_name, r.role_code
     FROM users u
     LEFT JOIN roles r ON u.role_id = r.id
     WHERE u.id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function createUser(data) {
  const { username, full_name, email, phone, role_id, password_hash, is_active } = data;
  if (!username || !full_name || !role_id) {
    throw new Error('Username, Full Name, and Role are compulsory');
  }

  const existing = await db.query('SELECT id FROM users WHERE username = $1', [username]);
  if (existing.length > 0) {
    throw new Error(`Username "${username}" is already taken`);
  }

  const res = await db.query(
    `INSERT INTO users (username, full_name, email, phone, role_id, password_hash, is_active)
     VALUES ($1, $2, $3, $4, $5, $6, $7)`,
    [
      username,
      full_name,
      email || null,
      phone || null,
      role_id,
      password_hash || 'user@123',
      is_active !== undefined ? is_active : 1
    ]
  );
  return await getUserById(res[0]?.id);
}

async function updateUser(id, data) {
  const existing = await getUserById(id);
  if (!existing) throw new Error('User not found');

  const { full_name, email, phone, role_id, password_hash, is_active } = data;

  let query = `
    UPDATE users
    SET full_name = $1, email = $2, phone = $3, role_id = $4, is_active = $5
  `;
  const params = [
    full_name !== undefined ? full_name : existing.full_name,
    email !== undefined ? email : existing.email,
    phone !== undefined ? phone : existing.phone,
    role_id !== undefined ? role_id : existing.role_id,
    is_active !== undefined ? is_active : existing.is_active
  ];

  if (password_hash) {
    params.push(password_hash);
    query += `, password_hash = $${params.length}`;
  }

  params.push(id);
  query += ` WHERE id = $${params.length}`;

  await db.query(query, params);
  return await getUserById(id);
}

async function deleteUser(id) {
  const existing = await getUserById(id);
  if (!existing) throw new Error('User not found');

  // Soft delete
  await db.query('UPDATE users SET is_active = 0 WHERE id = $1', [id]);
  return true;
}

module.exports = {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser
};
