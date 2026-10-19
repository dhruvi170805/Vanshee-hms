const db = require('../config/database');

async function seedData() {
  console.log('🌱 Checking and seeding initial sample data...');

  const existingClassifications = await db.query('SELECT COUNT(*) as count FROM medicine_classifications');
  const count = existingClassifications[0]?.count || 0;

  if (count === 0) {
    // Insert Classifications
  const classifications = [
    { code: 'ANALGESIC', name: 'Analgesics & Pain Relievers', description: 'Medications used to relieve pain and reduce fever', is_active: 1 },
    { code: 'ANTIBIOTIC', name: 'Antibiotics & Anti-Infectives', description: 'Medications used to treat bacterial infections', is_active: 1 },
    { code: 'ANTIHISTAMINE', name: 'Antihistamines & Allergy Relief', description: 'Medications that block histamine to treat allergy symptoms', is_active: 1 },
    { code: 'CARDIOVASCULAR', name: 'Cardiovascular Medications', description: 'Drugs used for treating heart conditions and hypertension', is_active: 1 },
    { code: 'ANTIDIABETIC', name: 'Antidiabetics & Insulin', description: 'Medications used to control high blood sugar levels in diabetes', is_active: 1 },
    { code: 'RESPIRATORY', name: 'Respiratory & Inhalers', description: 'Treatments for asthma, COPD, and airway congestion', is_active: 1 }
  ];

  for (const c of classifications) {
    await db.query(
      `INSERT INTO medicine_classifications (code, name, description, is_active) VALUES ($1, $2, $3, $4)`,
      [c.code, c.name, c.description, c.is_active]
    );
  }

  // Get inserted classification IDs
  const classRows = await db.query('SELECT id, code FROM medicine_classifications');
  const classMap = {};
  classRows.forEach(r => { classMap[r.code] = r.id; });

  // Insert Sample Medicines
  const medicines = [
    {
      classification_id: classMap['ANALGESIC'],
      name: 'Paracetamol Extra 500mg',
      generic_name: 'Acetaminophen',
      sku_code: 'MED-ANAL-001',
      manufacturer: 'Apex Pharma Ltd',
      unit: 'Tablet',
      dosage_strength: '500mg',
      price: 12.50,
      stock_quantity: 450,
      reorder_level: 100,
      is_active: 1
    },
    {
      classification_id: classMap['ANALGESIC'],
      name: 'Ibuprofen Rapid 400mg',
      generic_name: 'Ibuprofen',
      sku_code: 'MED-ANAL-002',
      manufacturer: 'HealthCare Corp',
      unit: 'Tablet',
      dosage_strength: '400mg',
      price: 18.00,
      stock_quantity: 25, // Low stock!
      reorder_level: 50,
      is_active: 1
    },
    {
      classification_id: classMap['ANTIBIOTIC'],
      name: 'Amoxicillin Trihydrate',
      generic_name: 'Amoxicillin',
      sku_code: 'MED-ANTI-001',
      manufacturer: 'BioCure Labs',
      unit: 'Capsule',
      dosage_strength: '500mg',
      price: 45.00,
      stock_quantity: 120,
      reorder_level: 40,
      is_active: 1
    },
    {
      classification_id: classMap['ANTIBIOTIC'],
      name: 'Azithromycin Oral Suspension',
      generic_name: 'Azithromycin',
      sku_code: 'MED-ANTI-002',
      manufacturer: 'BioCure Labs',
      unit: 'Syrup',
      dosage_strength: '200mg/5ml',
      price: 95.00,
      stock_quantity: 5, // Low stock!
      reorder_level: 20,
      is_active: 1
    },
    {
      classification_id: classMap['ANTIHISTAMINE'],
      name: 'Cetirizine Hydrochloride',
      generic_name: 'Cetirizine',
      sku_code: 'MED-HIST-001',
      manufacturer: 'Allergy Care Inc',
      unit: 'Tablet',
      dosage_strength: '10mg',
      price: 15.00,
      stock_quantity: 300,
      reorder_level: 50,
      is_active: 1
    },
    {
      classification_id: classMap['CARDIOVASCULAR'],
      name: 'Amlodipine Besylate',
      generic_name: 'Amlodipine',
      sku_code: 'MED-CARD-001',
      manufacturer: 'CardioLife Labs',
      unit: 'Tablet',
      dosage_strength: '5mg',
      price: 28.50,
      stock_quantity: 0, // Out of stock!
      reorder_level: 30,
      is_active: 1
    },
    {
      classification_id: classMap['ANTIDIABETIC'],
      name: 'Metformin Hydrochloride 500mg',
      generic_name: 'Metformin',
      sku_code: 'MED-DIAB-001',
      manufacturer: 'GlucoCare Pharma',
      unit: 'Tablet',
      dosage_strength: '500mg',
      price: 22.00,
      stock_quantity: 210,
      reorder_level: 50,
      is_active: 1
    }
  ];

  for (const m of medicines) {
    await db.query(
      `INSERT INTO medicines (classification_id, name, generic_name, sku_code, manufacturer, unit, dosage_strength, price, stock_quantity, reorder_level, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
      [m.classification_id, m.name, m.generic_name, m.sku_code, m.manufacturer, m.unit, m.dosage_strength, m.price, m.stock_quantity, m.reorder_level, m.is_active]
    );
  }
}

  // Seed Suppliers if empty
  const existingSuppliers = await db.query('SELECT COUNT(*) as count FROM medicine_suppliers');
  if ((existingSuppliers[0]?.count || 0) === 0) {
    const suppliers = [
      { code: 'SUP-001', name: 'AyurVeda Pharmaceuticals Pvt Ltd', contact_person: 'Dr. V. K. Shastri', phone: '+91 98250 11223', email: 'sales@ayurvedapharma.com', address: 'Plot 42, GIDC Industrial Estate', city: 'Ahmedabad', gstin: '24AAACA1234A1Z5', dl_number: 'DL-GJ-AYU-8821' },
      { code: 'SUP-002', name: 'PhysioCare Instruments & Mobility', contact_person: 'Rakesh Mehta', phone: '+91 98980 44556', email: 'orders@physiocareindia.com', address: '12 Health Plaza, Ring Road', city: 'Vadodara', gstin: '24BBBCB5678B1Z2', dl_number: 'DL-GJ-MED-4412' },
      { code: 'SUP-003', name: 'Apex Healthcare & Life Sciences', contact_person: 'Sunil Nair', phone: '+91 97240 77889', email: 'support@apexhealthcare.in', address: '88 Pharma Park, Sector 4', city: 'Surat', gstin: '24CCCC9012C1Z8', dl_number: 'DL-GJ-ALLO-9910' }
    ];

    for (const s of suppliers) {
      await db.query(
        `INSERT INTO medicine_suppliers (code, name, contact_person, phone, email, address, city, gstin, dl_number, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 1)`,
        [s.code, s.name, s.contact_person, s.phone, s.email, s.address, s.city, s.gstin, s.dl_number]
      );
    }

    // Insert sample purchase record
    const suppRows = await db.query('SELECT id FROM medicine_suppliers LIMIT 1');
    const medRows = await db.query('SELECT id, price FROM medicines LIMIT 2');
    if (suppRows.length > 0 && medRows.length > 0) {
      const purRes = await db.query(
        `INSERT INTO purchases (invoice_no, supplier_id, purchase_date, payment_status, payment_mode, subtotal, tax_amount, discount_amount, total_amount, notes)
         VALUES ($1, $2, date('now'), 'Paid', 'Bank Transfer', 12500.0, 625.0, 125.0, 13000.0, 'Batch stock replenishment for central pharmacy')`,
        ['PUR-2026-001', suppRows[0].id]
      );
      const purchaseId = purRes[0]?.id;
      if (purchaseId) {
        await db.query(
          `INSERT INTO purchase_items (purchase_id, medicine_id, quantity, unit_price, batch_no, expiry_date, total_price)
           VALUES ($1, $2, 100, 10.0, 'BAT-2026-X1', '2027-12-31', 1000.0)`,
          [purchaseId, medRows[0].id]
        );
      }
    }
    console.log(' Medicine Suppliers & Purchases seeded successfully.');
  }

  // Seed Patients if empty
  const existingPatients = await db.query('SELECT COUNT(*) as count FROM patients');
  if ((existingPatients[0]?.count || 0) === 0) {
    const samplePatients = [
      {
        patient_code: '0-1-AYU',
        name: 'Ramesh Patel',
        phone: '+91 98765 43210',
        email: 'ramesh.patel@gmail.com',
        age: 46,
        weight: 68.5,
        gender: 'Male',
        date_of_birth: '1980-04-15',
        department: 'Ayurvedic',
        patient_type: 'OPD',
        doctor_name: 'Dr. H. N. Patel',
        blood_group: 'B+',
        address: '14 Shantivan Society, Station Road',
        chief_complaint: 'Chronic knee joint stiffness & Vat dosha imbalance',
        diagnosis: 'Sandhivata (Osteoarthritis)',
        status: 'Active'
      },
      {
        patient_code: '0-2-AYU',
        name: 'Meena Shah',
        phone: '+91 98234 56789',
        email: '',
        age: 34,
        weight: 54.0,
        gender: 'Female',
        date_of_birth: '1992-08-20',
        department: 'Ayurvedic',
        patient_type: 'OPD',
        doctor_name: 'Dr. H. N. Patel',
        blood_group: 'O+',
        address: '42 Gokuldham, Bopal',
        chief_complaint: 'Hyperacidity and digestive distress',
        diagnosis: 'Amlapitta',
        status: 'Active'
      },
      {
        patient_code: '0-1-PT',
        name: 'Ankit Sharma',
        phone: '+91 98112 23344',
        email: 'ankit.s@outlook.com',
        age: 29,
        weight: 72.0,
        gender: 'Male',
        date_of_birth: '1997-01-10',
        department: 'Physiotherapy',
        patient_type: 'OPD',
        doctor_name: 'Dr. Priya Desai (PT)',
        blood_group: 'A+',
        address: 'B-201 Silicon Heights, SG Highway',
        chief_complaint: 'Post-sports ACL rehabilitation & lower lumbar strain',
        diagnosis: 'Lumbar Strain & ACL Recovery',
        status: 'Active'
      },
      {
        patient_code: '0-2-PT',
        name: 'Sunita Devi',
        phone: '+91 98998 87766',
        email: '',
        age: 52,
        weight: 61.5,
        gender: 'Female',
        date_of_birth: '1974-11-05',
        department: 'Physiotherapy',
        patient_type: 'OPD',
        doctor_name: 'Dr. Priya Desai (PT)',
        blood_group: 'AB+',
        address: 'Plot 9, Shivalik Nagar',
        chief_complaint: 'Frozen shoulder (adhesive capsulitis) right side',
        diagnosis: 'Adhesive Capsulitis',
        status: 'Active'
      },
      {
        patient_code: '0-1-AYU(IPD)',
        name: 'Rajendra Prasad',
        phone: '+91 97123 45678',
        email: 'rajendra.p@gmail.com',
        age: 63,
        weight: 75.0,
        gender: 'Male',
        date_of_birth: '1963-06-12',
        department: 'Ayurvedic',
        patient_type: 'Indoor',
        ward_bed_no: 'Ward A - Bed 04',
        admission_date: new Date(Date.now() - 2 * 24 * 3600 * 1000).toISOString(),
        doctor_name: 'Dr. H. N. Patel',
        blood_group: 'B+',
        address: 'C-10 Shantinagar, Ashram Road',
        chief_complaint: 'Severe sciatica pain with restricted leg mobility',
        diagnosis: 'Gridhrasi (Sciatica) - Panchakarma Protocol',
        status: 'Admitted'
      },
      {
        patient_code: '0-1-PT(IPD)',
        name: 'Priya Verma',
        phone: '+91 99245 67890',
        email: '',
        age: 38,
        weight: 58.0,
        gender: 'Female',
        date_of_birth: '1988-02-14',
        department: 'Physiotherapy',
        patient_type: 'Indoor',
        ward_bed_no: 'Rehab Ward - Bed 02',
        admission_date: new Date(Date.now() - 1 * 24 * 3600 * 1000).toISOString(),
        doctor_name: 'Dr. Priya Desai (PT)',
        blood_group: 'O+',
        address: '55 Green Meadows, Vastrapur',
        chief_complaint: 'Post-total knee arthroplasty inpatient rehabilitation',
        diagnosis: 'Post-TKR Intensive Inpatient Rehab',
        status: 'Admitted'
      }
    ];

    for (const p of samplePatients) {
      await db.query(
        `INSERT INTO patients (patient_code, name, phone, email, age, weight, gender, date_of_birth, department, patient_type, ward_bed_no, admission_date, doctor_name, blood_group, address, chief_complaint, diagnosis, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)`,
        [p.patient_code, p.name, p.phone, p.email, p.age, p.weight, p.gender, p.date_of_birth, p.department, p.patient_type, p.ward_bed_no, p.admission_date, p.doctor_name, p.blood_group, p.address, p.chief_complaint, p.diagnosis, p.status]
      );
    }
    console.log(' Sample Patients seeded successfully.');
  }

  // Seed Appointments if empty
  const existingAppts = await db.query('SELECT COUNT(*) as count FROM appointments');
  if ((existingAppts[0]?.count || 0) === 0) {
    const todayStr = new Date().toISOString().split('T')[0];
    const sampleAppointments = [
      {
        patient_code: '0-1-AYU',
        patient_name: 'Ramesh Patel',
        department: 'Ayurvedic',
        doctor_name: 'Dr. H. N. Patel',
        appointment_date: todayStr,
        appointment_time: '10:00 AM',
        token_number: 1,
        reason: 'Janu Basti & Ayurvedic consultation follow-up',
        status: 'In-Consultation'
      },
      {
        patient_code: '0-2-AYU',
        patient_name: 'Meena Shah',
        department: 'Ayurvedic',
        doctor_name: 'Dr. H. N. Patel',
        appointment_date: todayStr,
        appointment_time: '10:30 AM',
        token_number: 2,
        reason: 'Dietary counseling & herbal prescription review',
        status: 'Scheduled'
      },
      {
        patient_code: '0-1-PT',
        patient_name: 'Ankit Sharma',
        department: 'Physiotherapy',
        doctor_name: 'Dr. Priya Desai (PT)',
        appointment_date: todayStr,
        appointment_time: '11:15 AM',
        token_number: 1,
        reason: 'Electrotherapy & quadriceps isometric strengthening',
        status: 'Scheduled'
      },
      {
        patient_code: '0-2-PT',
        patient_name: 'Sunita Devi',
        department: 'Physiotherapy',
        doctor_name: 'Dr. Priya Desai (PT)',
        appointment_date: todayStr,
        appointment_time: '12:00 PM',
        token_number: 2,
        reason: 'Ultrasound therapy & passive shoulder mobilization',
        status: 'Scheduled'
      }
    ];

    for (const a of sampleAppointments) {
      await db.query(
        `INSERT INTO appointments (patient_code, patient_name, department, doctor_name, appointment_date, appointment_time, token_number, reason, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [a.patient_code, a.patient_name, a.department, a.doctor_name, a.appointment_date, a.appointment_time, a.token_number, a.reason, a.status]
      );
    }
    console.log(' Sample Appointments seeded successfully.');
  }

  // Seed System Modules if empty
  const existingModules = await db.query('SELECT COUNT(*) as count FROM system_modules');
  if ((existingModules[0]?.count || 0) === 0) {
    const modules = [
      { key: 'dashboard', name: 'Dashboard Overview', category: 'Overview', desc: 'Central hospital KPIs, clinical queues, stock alerts, and audit logs' },
      { key: 'patients', name: 'Patient Directory & Add Patient', category: 'Clinical Care', desc: 'Complete patient registration and medical profiling' },
      { key: 'opd_list', name: 'OPD Queue (Ayu & PT)', category: 'Clinical Care', desc: 'Ayurvedic and Physiotherapy outpatient consultation queue' },
      { key: 'indoor_list', name: 'Indoor Patient List (IPD)', category: 'Clinical Care', desc: 'Inpatient ward admission tracking and bed allocation' },
      { key: 'appointments', name: 'Doctor Appointments', category: 'Clinical Care', desc: 'Doctor token scheduling and consultation appointments' },
      { key: 'doctors', name: 'Doctor Master', category: 'Masters & Setup', desc: 'Doctor profiles, specialties, departments, and consultation fees' },
      { key: 'rooms', name: 'Room & Ward Master', category: 'Masters & Setup', desc: 'Hospital rooms, wards, bed availability and daily charges' },
      { key: 'lab_report', name: 'Lab Reports', category: 'Clinical Care', desc: 'Pathology and diagnostic lab test results management' },
      { key: 'payment', name: 'Payments & Billing', category: 'Billing', desc: 'Patient payment receipts, billing summary and payment modes' },
      { key: 'classification', name: 'Medicine Classification Master', category: 'Masters & Setup', desc: 'Therapeutic categories and medication drug classes' },
      { key: 'medicine', name: 'Medicine Master', category: 'Masters & Setup', desc: 'Pharmacy inventory catalog, batch codes, and price lists' },
      { key: 'suppliers', name: 'Medicine Supplier Master', category: 'Masters & Setup', desc: 'Pharmaceutical vendors, drug license records, and GSTIN' },
      { key: 'purchases', name: 'Purchase Master', category: 'Masters & Setup', desc: 'Purchase orders, invoice bills, and auto-stock increments' },
      { key: 'user_master', name: 'User Master', category: 'Administration', desc: 'Hospital user accounts and custom role permission assignments' },
      { key: 'role_master', name: 'Role Master', category: 'Administration', desc: 'Role definitions (Doctor, Receptionist, Patient, Admin)' },
      { key: 'module_master', name: 'Module Master', category: 'Administration', desc: 'System feature modules registration and configuration' }
    ];

    for (const m of modules) {
      await db.query(
        `INSERT INTO system_modules (module_key, module_name, category, description, is_active)
         VALUES ($1, $2, $3, $4, 1)`,
        [m.key, m.name, m.category, m.desc]
      );
    }
    console.log(' System Modules seeded successfully.');
  }

  // Seed Roles if empty
  const existingRoles = await db.query('SELECT COUNT(*) as count FROM roles');
  if ((existingRoles[0]?.count || 0) === 0) {
    const roles = [
      { code: 'ADMIN', name: 'Hospital Administrator', desc: 'Full system administrative control including user permissions and master settings' },
      { code: 'DOCTOR', name: 'Doctor / Chief Physician', desc: 'Full medical, pharmacy, and operational access across the entire hospital system' },
      { code: 'RECEPTIONIST', name: 'Receptionist / Front Desk', desc: 'Front desk reception access: OPD queue, patient registration, and appointment booking' },
      { code: 'PATIENT', name: 'Patient / Hospital Portal', desc: 'Patient self-service portal: view personal appointments and OPD queue status' },
      { code: 'LAB_TECH', name: 'Lab Technician', desc: 'Laboratory technician access: manage lab reports and test results' }
    ];

    for (const r of roles) {
      await db.query(
        `INSERT INTO roles (role_code, role_name, description, is_active)
         VALUES ($1, $2, $3, 1)`,
        [r.code, r.name, r.desc]
      );
    }
    console.log(' System Roles seeded successfully.');
  }

  // Seed Users & User Permissions if empty
  const existingUsers = await db.query('SELECT COUNT(*) as count FROM users');
  if ((existingUsers[0]?.count || 0) === 0) {
    const roleRows = await db.query('SELECT id, role_code FROM roles');
    const roleMap = {};
    roleRows.forEach(r => { roleMap[r.role_code] = r.id; });

    const allModuleKeys = [
      'dashboard', 'patients', 'opd_list', 'indoor_list', 'appointments',
      'doctors', 'rooms', 'lab_report', 'payment',
      'classification', 'medicine', 'suppliers', 'purchases',
      'user_master', 'role_master', 'module_master'
    ];

    const sampleUsers = [
      {
        username: 'admin',
        full_name: 'System Administrator',
        email: 'admin@hospital.org',
        phone: '+91 98250 99999',
        role_code: 'ADMIN',
        password_hash: 'admin@123',
        permissions: allModuleKeys.map(k => ({ key: k, view: 1, create: 1, edit: 1, del: 1 }))
      },
      {
        username: 'dr_patel',
        full_name: 'Dr. H. N. Patel',
        email: 'dr.patel@hospital.org',
        phone: '+91 98250 11001',
        role_code: 'DOCTOR',
        password_hash: 'doctor@123',
        permissions: allModuleKeys.map(k => ({ key: k, view: 1, create: 1, edit: 1, del: 1 }))
      },
      {
        username: 'anita_reception',
        full_name: 'Anita Sharma (Receptionist)',
        email: 'anita.reception@hospital.org',
        phone: '+91 98250 22002',
        role_code: 'RECEPTIONIST',
        password_hash: 'recept@123',
        permissions: [
          { key: 'dashboard', view: 1, create: 0, edit: 0, del: 0 },
          { key: 'patients', view: 1, create: 1, edit: 1, del: 0 },
          { key: 'opd_list', view: 1, create: 1, edit: 1, del: 0 },
          { key: 'indoor_list', view: 1, create: 0, edit: 0, del: 0 },
          { key: 'appointments', view: 1, create: 1, edit: 1, del: 0 },
          { key: 'payment', view: 1, create: 1, edit: 0, del: 0 }
        ]
      },
      {
        username: 'ramesh_patient',
        full_name: 'Ramesh Patel (Patient)',
        email: 'ramesh.patel@gmail.com',
        phone: '+91 98765 43210',
        role_code: 'PATIENT',
        password_hash: 'patient@123',
        permissions: [
          { key: 'dashboard', view: 1, create: 0, edit: 0, del: 0 },
          { key: 'appointments', view: 1, create: 0, edit: 0, del: 0 },
          { key: 'opd_list', view: 1, create: 0, edit: 0, del: 0 }
        ]
      },
      {
        username: 'lab_tech1',
        full_name: 'Deepak Verma (Lab Tech)',
        email: 'deepak.lab@hospital.org',
        phone: '+91 98250 33003',
        role_code: 'LAB_TECH',
        password_hash: 'labtech@123',
        permissions: [
          { key: 'dashboard', view: 1, create: 0, edit: 0, del: 0 },
          { key: 'patients', view: 1, create: 0, edit: 0, del: 0 },
          { key: 'lab_report', view: 1, create: 1, edit: 1, del: 0 }
        ]
      }
    ];

    for (const u of sampleUsers) {
      const roleId = roleMap[u.role_code];
      const userRes = await db.query(
        `INSERT INTO users (username, full_name, email, phone, role_id, password_hash, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, 1)`,
        [u.username, u.full_name, u.email, u.phone, roleId, u.password_hash]
      );
      const userId = userRes[0]?.id;

      if (userId && u.permissions) {
        for (const p of u.permissions) {
          await db.query(
            `INSERT INTO user_permissions (user_id, module_key, can_view, can_create, can_edit, can_delete)
             VALUES ($1, $2, $3, $4, $5, $6)`,
            [userId, p.key, p.view, p.create, p.edit, p.del]
          );
        }
      }
    }
    console.log(' Hospital Users and User Permissions seeded successfully.');
  }

  // Ensure default passwords are populated for sample users
  try {
    await db.query("UPDATE users SET password_hash = 'admin@123' WHERE username = 'admin' AND (password_hash IS NULL OR password_hash = '')");
    await db.query("UPDATE users SET password_hash = 'doctor@123' WHERE username = 'dr_patel' AND (password_hash IS NULL OR password_hash = '')");
    await db.query("UPDATE users SET password_hash = 'recept@123' WHERE username = 'anita_reception' AND (password_hash IS NULL OR password_hash = '')");
    await db.query("UPDATE users SET password_hash = 'patient@123' WHERE username = 'ramesh_patient' AND (password_hash IS NULL OR password_hash = '')");
  } catch(e) {}

  // Seed Doctors if empty
  const existingDoctors = await db.query('SELECT COUNT(*) as count FROM doctors');
  if ((existingDoctors[0]?.count || 0) === 0) {
    const doctors = [
      {
        doctor_code: 'DR-001',
        full_name: 'Dr. H. N. Patel',
        specialty: 'Ayurvedic Medicine',
        department: 'Ayurvedic',
        phone: '+91 98250 11001',
        email: 'dr.patel@hospital.org',
        qualification: 'BAMS, MD (Ayurveda)',
        experience_years: 18,
        consultation_fee: 500,
        is_active: 1
      },
      {
        doctor_code: 'DR-002',
        full_name: 'Dr. Priya Desai',
        specialty: 'Physiotherapy & Rehabilitation',
        department: 'Physiotherapy',
        phone: '+91 98765 22002',
        email: 'dr.desai@hospital.org',
        qualification: 'BPTh, MPTh (Ortho)',
        experience_years: 12,
        consultation_fee: 400,
        is_active: 1
      },
      {
        doctor_code: 'DR-003',
        full_name: 'Dr. Suresh Mehta',
        specialty: 'General Medicine',
        department: 'General',
        phone: '+91 97240 33003',
        email: 'dr.mehta@hospital.org',
        qualification: 'MBBS, MD (General Medicine)',
        experience_years: 20,
        consultation_fee: 600,
        is_active: 1
      },
      {
        doctor_code: 'DR-004',
        full_name: 'Dr. Anjali Rao',
        specialty: 'Pediatrics',
        department: 'Pediatrics',
        phone: '+91 99876 44004',
        email: 'dr.rao@hospital.org',
        qualification: 'MBBS, DCH, MD (Pediatrics)',
        experience_years: 9,
        consultation_fee: 450,
        is_active: 1
      }
    ];

    for (const d of doctors) {
      await db.query(
        `INSERT INTO doctors (doctor_code, full_name, specialty, department, phone, email, qualification, experience_years, consultation_fee, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [d.doctor_code, d.full_name, d.specialty, d.department, d.phone, d.email, d.qualification, d.experience_years, d.consultation_fee, d.is_active]
      );
    }
    console.log(' Sample Doctors seeded successfully.');
  }

  // Seed Rooms if empty
  const existingRooms = await db.query('SELECT COUNT(*) as count FROM rooms');
  if ((existingRooms[0]?.count || 0) === 0) {
    const rooms = [
      { room_number: 'R-101', ward_name: 'General Ward A', room_type: 'General', total_beds: 6, occupied_beds: 2, floor_number: 1, daily_charge: 500, status: 'Available' },
      { room_number: 'R-201', ward_name: 'Ayurvedic Ward', room_type: 'General', total_beds: 4, occupied_beds: 1, floor_number: 2, daily_charge: 800, status: 'Available' },
      { room_number: 'R-202', ward_name: 'Rehab Ward', room_type: 'General', total_beds: 4, occupied_beds: 1, floor_number: 2, daily_charge: 700, status: 'Available' },
      { room_number: 'R-301', ward_name: 'Private Suite', room_type: 'Private', total_beds: 1, occupied_beds: 0, floor_number: 3, daily_charge: 2500, status: 'Available' },
      { room_number: 'ICU-01', ward_name: 'Intensive Care Unit', room_type: 'ICU', total_beds: 4, occupied_beds: 0, floor_number: 1, daily_charge: 5000, status: 'Available' }
    ];

    for (const r of rooms) {
      await db.query(
        `INSERT INTO rooms (room_number, ward_name, room_type, total_beds, occupied_beds, floor_number, daily_charge, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [r.room_number, r.ward_name, r.room_type, r.total_beds, r.occupied_beds, r.floor_number, r.daily_charge, r.status]
      );
    }
    console.log(' Sample Rooms seeded successfully.');
  }

  // Insert initial activity logs
  await db.query(
    `INSERT INTO activity_logs (action, details) VALUES ($1, $2)`,
    ['SYSTEM_INIT', 'Database schema initialized and sample clinical, pharmacy & user access records populated.']
  );

  console.log(' Sample data seeded successfully!');
}

module.exports = { seedData };
