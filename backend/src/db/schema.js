const db = require('../config/database');

async function createSchema() {
  console.log('📦 Initializing Database Tables...');

  const createClassificationsTable = `
    CREATE TABLE IF NOT EXISTS medicine_classifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code VARCHAR(50) UNIQUE NOT NULL,
      name VARCHAR(150) NOT NULL,
      description TEXT,
      is_active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createMedicinesTable = `
    CREATE TABLE IF NOT EXISTS medicines (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      classification_id INTEGER NOT NULL,
      name VARCHAR(200) NOT NULL,
      generic_name VARCHAR(200),
      sku_code VARCHAR(50) UNIQUE NOT NULL,
      manufacturer VARCHAR(150),
      unit VARCHAR(50) DEFAULT 'Tablet',
      dosage_strength VARCHAR(50),
      price REAL NOT NULL DEFAULT 0.0,
      stock_quantity INTEGER NOT NULL DEFAULT 0,
      reorder_level INTEGER NOT NULL DEFAULT 10,
      is_active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (classification_id) REFERENCES medicine_classifications (id) ON DELETE CASCADE
    );
  `;

  const createActivityLogsTable = `
    CREATE TABLE IF NOT EXISTS activity_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      action VARCHAR(100) NOT NULL,
      details TEXT NOT NULL,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createSuppliersTable = `
    CREATE TABLE IF NOT EXISTS medicine_suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code VARCHAR(50) UNIQUE NOT NULL,
      name VARCHAR(200) NOT NULL,
      contact_person VARCHAR(150),
      phone VARCHAR(30) NOT NULL,
      email VARCHAR(150),
      address TEXT,
      city VARCHAR(100),
      gstin VARCHAR(50),
      dl_number VARCHAR(50),
      is_active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createPurchasesTable = `
    CREATE TABLE IF NOT EXISTS purchases (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_no VARCHAR(50) UNIQUE NOT NULL,
      supplier_id INTEGER NOT NULL,
      purchase_date DATE NOT NULL,
      payment_status VARCHAR(50) DEFAULT 'Paid',
      payment_mode VARCHAR(50) DEFAULT 'Bank Transfer',
      subtotal REAL DEFAULT 0.0,
      tax_amount REAL DEFAULT 0.0,
      discount_amount REAL DEFAULT 0.0,
      total_amount REAL NOT NULL DEFAULT 0.0,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (supplier_id) REFERENCES medicine_suppliers (id) ON DELETE CASCADE
    );
  `;

  const createPurchaseItemsTable = `
    CREATE TABLE IF NOT EXISTS purchase_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      purchase_id INTEGER NOT NULL,
      medicine_id INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL,
      batch_no VARCHAR(50),
      expiry_date VARCHAR(50),
      total_price REAL NOT NULL,
      FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE CASCADE,
      FOREIGN KEY (medicine_id) REFERENCES medicines (id) ON DELETE CASCADE
    );
  `;

  const createPatientsTable = `
    CREATE TABLE IF NOT EXISTS patients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_code VARCHAR(50) UNIQUE NOT NULL,
      name VARCHAR(200) NOT NULL,
      phone VARCHAR(30) NOT NULL,
      email VARCHAR(150),
      age INTEGER NOT NULL,
      weight REAL NOT NULL,
      gender VARCHAR(20) NOT NULL,
      date_of_birth DATE,
      department VARCHAR(50) NOT NULL,
      patient_type VARCHAR(50) NOT NULL,
      ward_bed_no VARCHAR(50),
      admission_date DATETIME,
      doctor_name VARCHAR(150),
      blood_group VARCHAR(10),
      address TEXT,
      chief_complaint TEXT,
      diagnosis TEXT,
      status VARCHAR(50) DEFAULT 'Active',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createAppointmentsTable = `
    CREATE TABLE IF NOT EXISTS appointments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_id INTEGER,
      patient_code VARCHAR(50),
      patient_name VARCHAR(200),
      department VARCHAR(50) NOT NULL,
      doctor_name VARCHAR(150),
      appointment_date DATE NOT NULL,
      appointment_time VARCHAR(20) NOT NULL,
      token_number INTEGER NOT NULL,
      reason TEXT,
      status VARCHAR(50) DEFAULT 'Scheduled',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE SET NULL
    );
  `;

  const createSystemModulesTable = `
    CREATE TABLE IF NOT EXISTS system_modules (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      module_key VARCHAR(50) UNIQUE NOT NULL,
      module_name VARCHAR(100) NOT NULL,
      category VARCHAR(50) NOT NULL,
      description TEXT,
      is_active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createRolesTable = `
    CREATE TABLE IF NOT EXISTS roles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      role_code VARCHAR(50) UNIQUE NOT NULL,
      role_name VARCHAR(100) NOT NULL,
      description TEXT,
      is_active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createUsersTable = `
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username VARCHAR(50) UNIQUE NOT NULL,
      full_name VARCHAR(150) NOT NULL,
      email VARCHAR(150),
      phone VARCHAR(30),
      role_id INTEGER NOT NULL,
      is_active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT
    );
  `;

  const createUserPermissionsTable = `
    CREATE TABLE IF NOT EXISTS user_permissions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      module_key VARCHAR(50) NOT NULL,
      can_view INTEGER DEFAULT 1,
      can_create INTEGER DEFAULT 0,
      can_edit INTEGER DEFAULT 0,
      can_delete INTEGER DEFAULT 0,
      UNIQUE(user_id, module_key),
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    );
  `;

  // --- New Tables ---

  const createDoctorsTable = `
    CREATE TABLE IF NOT EXISTS doctors (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      doctor_code VARCHAR(50) UNIQUE NOT NULL,
      full_name VARCHAR(200) NOT NULL,
      specialty VARCHAR(100),
      department VARCHAR(100),
      phone VARCHAR(30),
      email VARCHAR(150),
      qualification VARCHAR(200),
      experience_years INTEGER DEFAULT 0,
      consultation_fee REAL DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createRoomsTable = `
    CREATE TABLE IF NOT EXISTS rooms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      room_number VARCHAR(50) UNIQUE NOT NULL,
      ward_name VARCHAR(100) NOT NULL,
      room_type VARCHAR(50) DEFAULT 'General',
      total_beds INTEGER DEFAULT 1,
      occupied_beds INTEGER DEFAULT 0,
      floor_number INTEGER DEFAULT 1,
      daily_charge REAL DEFAULT 0,
      status VARCHAR(50) DEFAULT 'Available',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createLabReportsTable = `
    CREATE TABLE IF NOT EXISTS lab_reports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      report_no VARCHAR(50) UNIQUE NOT NULL,
      patient_id INTEGER,
      patient_code VARCHAR(50),
      patient_name VARCHAR(200),
      test_name VARCHAR(200) NOT NULL,
      test_category VARCHAR(100),
      doctor_name VARCHAR(150),
      sample_collected_at DATETIME,
      report_date DATE,
      result_value TEXT,
      normal_range VARCHAR(100),
      unit VARCHAR(50),
      status VARCHAR(50) DEFAULT 'Pending',
      remarks TEXT,
      charge REAL DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE SET NULL
    );
  `;

  const createPaymentsTable = `
    CREATE TABLE IF NOT EXISTS payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receipt_no VARCHAR(50) UNIQUE NOT NULL,
      patient_id INTEGER,
      patient_code VARCHAR(50),
      patient_name VARCHAR(200),
      payment_date DATE NOT NULL,
      amount REAL NOT NULL,
      payment_mode VARCHAR(50) DEFAULT 'Cash',
      payment_for VARCHAR(100) DEFAULT 'Consultation',
      status VARCHAR(50) DEFAULT 'Paid',
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE SET NULL
    );
  `;

  const createRolePermissionsTable = `
    CREATE TABLE IF NOT EXISTS role_permissions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      role_id INTEGER NOT NULL,
      module_key VARCHAR(50) NOT NULL,
      can_view INTEGER DEFAULT 1,
      can_create INTEGER DEFAULT 0,
      can_edit INTEGER DEFAULT 0,
      can_delete INTEGER DEFAULT 0,
      UNIQUE(role_id, module_key),
      FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
    );
  `;

  try {
    await db.query(createClassificationsTable);
    await db.query(createMedicinesTable);
    await db.query(createSuppliersTable);
    await db.query(createPurchasesTable);
    await db.query(createPurchaseItemsTable);
    await db.query(createPatientsTable);
    await db.query(createAppointmentsTable);
    await db.query(createActivityLogsTable);
    await db.query(createSystemModulesTable);
    await db.query(createRolesTable);
    await db.query(createUsersTable);
    await db.query(createUserPermissionsTable);
    // New tables
    await db.query(createDoctorsTable);
    await db.query(createRoomsTable);
    await db.query(createLabReportsTable);
    await db.query(createPaymentsTable);
    await db.query(createRolePermissionsTable);

    // Add password_hash column to users if not already present (idempotent migration)
    try {
      await db.query(`ALTER TABLE users ADD COLUMN password_hash TEXT`);
    } catch(e) { /* column may already exist */ }

    console.log(' Database tables initialized successfully');
  } catch (err) {
    console.error('❌ Schema initialization error:', err);
    throw err;
  }
}

module.exports = { createSchema };
