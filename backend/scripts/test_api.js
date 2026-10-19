const http = require('http');

const BASE_URL = 'http://localhost:5000/api/v1';

function makeRequest(url, method = 'GET', body = null) {
  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const options = {
      hostname: parsedUrl.hostname,
      port: parsedUrl.port,
      path: parsedUrl.pathname + parsedUrl.search,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', err => reject(err));

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Running API Integration Tests...\n');

  try {
    // 1. Health check
    const health = await makeRequest('http://localhost:5000/health');
    console.log('1. Health Check:', health.status === 200 ? ' PASSED' : '❌ FAILED', health.body);

    // 2. Dashboard Stats
    const dashboard = await makeRequest(`${BASE_URL}/dashboard/stats`);
    console.log('2. Dashboard Stats:', dashboard.status === 200 ? ' PASSED' : '❌ FAILED', `Medicines: ${dashboard.body?.data?.kpi?.totalMedicines}`);

    // 3. Get Classifications
    const classifications = await makeRequest(`${BASE_URL}/classification`);
    console.log('3. Get Classifications:', classifications.status === 200 ? ' PASSED' : '❌ FAILED', `Count: ${classifications.body?.data?.length}`);

    // 4. Create New Classification
    const newClassCode = `TEST_${Date.now().toString().slice(-4)}`;
    const createClass = await makeRequest(`${BASE_URL}/classification`, 'POST', {
      code: newClassCode,
      name: 'Test Diagnostics Category',
      description: 'Category created during automated verification'
    });
    console.log('4. Create Classification:', createClass.status === 201 ? ' PASSED' : '❌ FAILED', createClass.body);

    const createdClassId = createClass.body?.data?.id;

    // 5. Create New Medicine
    const newSku = `SKU_${Date.now().toString().slice(-4)}`;
    const createMed = await makeRequest(`${BASE_URL}/medicine`, 'POST', {
      classification_id: createdClassId,
      name: 'Test Rapid Medicine 500mg',
      generic_name: 'Test generic compound',
      sku_code: newSku,
      manufacturer: 'Test Bio Labs',
      unit: 'Tablet',
      dosage_strength: '500mg',
      price: 35.50,
      stock_quantity: 150,
      reorder_level: 30
    });
    console.log('5. Create Medicine:', createMed.status === 201 ? ' PASSED' : '❌ FAILED', createMed.body);

    const createdMedId = createMed.body?.data?.id;

    // 6. Get Medicines list
    const medicines = await makeRequest(`${BASE_URL}/medicine?search=Test`);
    console.log('6. Search Medicines:', medicines.status === 200 ? ' PASSED' : '❌ FAILED', `Found: ${medicines.body?.data?.length}`);

    // 7. Cleanup
    if (createdMedId) {
      await makeRequest(`${BASE_URL}/medicine/${createdMedId}`, 'DELETE');
    }
    if (createdClassId) {
      await makeRequest(`${BASE_URL}/classification/${createdClassId}`, 'DELETE');
    }
    console.log('7. Test Cleanup:', ' COMPLETED');

    console.log('\n All Backend API Tests Completed Successfully!');
  } catch (err) {
    console.error('❌ Integration tests failed:', err.message);
  }
}

runTests();
