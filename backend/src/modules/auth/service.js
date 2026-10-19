const db = require('../../config/database');

async function login(username, password) {
  const users = await db.query(
    'SELECT u.*, r.role_name, r.role_code FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE u.username = $1 AND u.is_active = 1',
    [username]
  );
  if (!users.length) throw new Error('Invalid username or password');
  const user = users[0];
  if (user.password_hash !== password) throw new Error('Invalid username or password');
  
  // Fetch user permissions or role permissions
  const permissions = await db.query(
    `SELECT module_key, can_view, can_create, can_edit, can_delete FROM user_permissions WHERE user_id = $1
     UNION
     SELECT module_key, can_view, can_create, can_edit, can_delete FROM role_permissions WHERE role_id = $2`,
    [user.id, user.role_id]
  );

  const token = Buffer.from(`${user.id}:${user.username}:${Date.now()}`).toString('base64');
  return {
    token,
    user: {
      id: user.id,
      username: user.username,
      full_name: user.full_name,
      email: user.email,
      phone: user.phone,
      role_name: user.role_name || 'Admin',
      role_code: user.role_code || 'ADMIN',
      role_id: user.role_id,
      permissions: permissions || []
    }
  };
}

module.exports = { login };
