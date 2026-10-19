const db = require('../src/config/database');

async function run() {
  await db.initDatabase();
  await db.query("UPDATE users SET password_hash = 'admin@123' WHERE username = 'admin'");
  await db.query("UPDATE users SET password_hash = 'doctor@123' WHERE username = 'dr_patel'");
  await db.query("UPDATE users SET password_hash = 'recept@123' WHERE username = 'anita_reception'");
  await db.query("UPDATE users SET password_hash = 'patient@123' WHERE username = 'ramesh_patient'");
  console.log('User passwords successfully updated!');
  const users = await db.query('SELECT id, username, password_hash FROM users');
  console.log(users);
  process.exit(0);
}

run();
