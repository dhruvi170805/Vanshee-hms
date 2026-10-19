const { initDatabase } = require('../src/config/database');
const { createSchema } = require('../src/db/schema');
const { seedData } = require('../src/db/seed');

const supplierService = require('../src/modules/supplier/service');
const purchaseService = require('../src/modules/purchase/service');
const patientService = require('../src/modules/patient/service');
const appointmentService = require('../src/modules/appointment/service');
const dashboardService = require('../src/modules/dashboard/service');

async function verify() {
  console.log('🧪 Starting Verification of New Backend Modules...\n');

  try {
    await initDatabase();
    await createSchema();
    await seedData();

    // 1. Supplier Master verification
    console.log('--- 1. Testing Supplier Master ---');
    const suppliers = await supplierService.getAllSuppliers();
    console.log(`Suppliers fetched: ${suppliers.length}`);
    if (suppliers.length === 0) throw new Error('Suppliers empty after seed');
    console.log(`Sample Supplier: ${suppliers[0].name} (${suppliers[0].code}) - Phone: ${suppliers[0].phone}`);

    // Test creating a supplier
    const newSupp = await supplierService.createSupplier({
      name: 'Patanjali Research Ayurveda',
      contact_person: 'Acharya Balkrishna',
      phone: '+91 98989 99999',
      city: 'Haridwar',
      email: 'sales@patanjali.org'
    });
    console.log(`Created Supplier: ${newSupp.name} (${newSupp.code})`);

    // 2. Purchase Master & Stock Auto-Increment verification
    console.log('\n--- 2. Testing Purchase Master & Auto-Stock Update ---');
    const purchases = await purchaseService.getAllPurchases();
    console.log(`Purchases count: ${purchases.length}`);

    // Check medicine stock before purchase
    const db = require('../src/config/database');
    const medBefore = await db.query('SELECT id, name, stock_quantity FROM medicines LIMIT 1');
    const testMedId = medBefore[0].id;
    const initialStock = medBefore[0].stock_quantity;
    console.log(`Medicine before purchase: ${medBefore[0].name}, Stock = ${initialStock}`);

    const newPurchase = await purchaseService.createPurchase({
      supplier_id: newSupp.id,
      purchase_date: '2026-10-12',
      payment_mode: 'UPI / Direct Debit',
      items: [
        {
          medicine_id: testMedId,
          quantity: 50,
          unit_price: 15.0,
          batch_no: 'BAT-2026-TEST',
          expiry_date: '2028-05-30'
        }
      ]
    });
    console.log(`Purchase bill created: ${newPurchase.invoice_no}, Total = ₹${newPurchase.total_amount}`);

    const medAfter = await db.query('SELECT stock_quantity FROM medicines WHERE id = $1', [testMedId]);
    console.log(`Medicine stock after purchase: ${medAfter[0].stock_quantity} (Expected: ${initialStock + 50})`);
    if (medAfter[0].stock_quantity !== initialStock + 50) {
      throw new Error('Stock quantity did not auto-increment correctly!');
    }

    // 3. Patient Service & Code Generation (0-1-AYU, 0-1-PT) & Validations
    console.log('\n--- 3. Testing Patient Service & Department OPD Codes ---');
    const codeAyu = await patientService.generateNextCode('Ayurvedic', 'OPD');
    console.log(`Generated Ayurvedic OPD Code: ${codeAyu}`);
    if (!codeAyu.includes('AYU')) throw new Error('Ayurvedic code should include AYU');

    const codePT = await patientService.generateNextCode('Physiotherapy', 'OPD');
    console.log(`Generated Physiotherapy OPD Code: ${codePT}`);
    if (!codePT.includes('PT')) throw new Error('Physiotherapy code should include PT');

    // Test compulsory validation: Missing phone should throw
    let caughtPhoneError = false;
    try {
      await patientService.createPatient({
        name: 'Incomplete Patient',
        phone: '', // missing
        age: 30,
        weight: 60,
        gender: 'Male'
      });
    } catch (e) {
      caughtPhoneError = true;
      console.log(` Compulsory Phone check caught: "${e.message}"`);
    }
    if (!caughtPhoneError) throw new Error('Compulsory phone validation failed!');

    // Test compulsory validation: Missing age / weight / gender
    let caughtWeightError = false;
    try {
      await patientService.createPatient({
        name: 'Incomplete Patient',
        phone: '9876543210',
        age: 30,
        weight: 0, // invalid weight
        gender: 'Male'
      });
    } catch (e) {
      caughtWeightError = true;
      console.log(` Compulsory Weight check caught: "${e.message}"`);
    }
    if (!caughtWeightError) throw new Error('Compulsory weight validation failed!');

    // Test successful creation with optional email and optional DOB left empty
    const createdAyuPatient = await patientService.createPatient({
      name: 'Vikas Dave',
      phone: '+91 99887 76655',
      email: '', // optional left blank
      age: 42,
      weight: 71.5,
      gender: 'Male',
      date_of_birth: null, // optional left blank
      department: 'Ayurvedic',
      patient_type: 'OPD',
      chief_complaint: 'Vatavyadhi and lower back ache'
    });
    console.log(` Registered Patient: ${createdAyuPatient.name} | Code: ${createdAyuPatient.patient_code} | Dept: ${createdAyuPatient.department}`);

    // Test Indoor Patient
    const createdIndoorPatient = await patientService.createPatient({
      name: 'Geeta Ben',
      phone: '+91 99112 23344',
      age: 55,
      weight: 62.0,
      gender: 'Female',
      department: 'Physiotherapy',
      patient_type: 'Indoor',
      ward_bed_no: 'IPD Ward 2 - Bed 05',
      chief_complaint: 'Post-spine surgery rehabilitation'
    });
    console.log(` Registered Indoor Patient: ${createdIndoorPatient.name} | Code: ${createdIndoorPatient.patient_code} | Bed: ${createdIndoorPatient.ward_bed_no}`);

    // 4. Appointments & Lists
    console.log('\n--- 4. Testing Appointments & Lists ---');
    const appointments = await appointmentService.getAllAppointments();
    console.log(`Appointments count: ${appointments.length}`);
    const opdList = await patientService.getOpdList();
    console.log(`OPD List count: ${opdList.length}`);
    const indoorList = await patientService.getIndoorList();
    console.log(`Indoor List count: ${indoorList.length}`);

    // 5. Dashboard Stats
    console.log('\n--- 5. Testing Dashboard Stats ---');
    const dash = await dashboardService.getDashboardStats();
    console.log('Dashboard KPI summary:', dash.kpi);
    console.log(`Dashboard OPD list length: ${dash.opdList.length}`);
    console.log(`Dashboard Indoor list length: ${dash.indoorList.length}`);
    console.log(`Dashboard Appointment list length: ${dash.appointmentList.length}`);

    console.log('\n ALL BACKEND MODULE TESTS PASSED WITH 100% SUCCESS!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Verification failed:', err);
    process.exit(1);
  }
}

verify();
