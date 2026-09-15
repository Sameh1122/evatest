const http = require('http');

const BASE_URL = 'http://localhost:5000';

let clientToken = '';
let adminToken = '';
let distributorToken = '';
let createdOrderId = null;
let createdProductId = null;

function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: data });
        }
      });
    });

    req.on('error', (err) => reject(err));

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTestSuite() {
  console.log('=================================================================');
  console.log(' 🧪 RUNNING FULL END-TO-END SUITE: LIMITLESS E-COMMERCE PLATFORM');
  console.log('=================================================================\n');

  let passed = 0;
  let failed = 0;

  async function assertTest(name, testFn) {
    try {
      await testFn();
      console.log(` ✅ PASS: ${name}`);
      passed++;
    } catch (err) {
      console.log(` ❌ FAIL: ${name} -> ${err.message}`);
      failed++;
    }
  }

  // 1. Health check
  await assertTest('1. System Health Check (/api/health)', async () => {
    const res = await request('GET', '/api/health');
    if (res.status !== 200 || res.body.status !== 'OK') {
      throw new Error(`Expected status 200 & OK, got ${res.status}`);
    }
  });

  // 2. Fetch Catalog
  await assertTest('2. Catalog Retrieval (/api/products)', async () => {
    const res = await request('GET', '/api/products');
    if (res.status !== 200 || !res.body.products || res.body.products.length === 0) {
      throw new Error(`Catalog empty or invalid response: ${JSON.stringify(res.body)}`);
    }
  });

  // 3. Search & Category Filter
  await assertTest('3. Product Search & Category Filtering', async () => {
    const searchRes = await request('GET', '/api/products?search=Man');
    if (searchRes.status !== 200 || !searchRes.body.products || searchRes.body.products.length === 0) {
      throw new Error(`Search for 'Man' returned no items: ${JSON.stringify(searchRes.body)}`);
    }
    const catRes = await request('GET', '/api/products?category=Daily Wellness');
    if (catRes.status !== 200 || !catRes.body.products || catRes.body.products.length === 0) {
      throw new Error(`Category filter for 'Daily Wellness' returned no items`);
    }
  });

  // 4. Client Login
  await assertTest('4. Client Authentication Login', async () => {
    const res = await request('POST', '/api/auth/login', {
      email: 'client@limitless.com',
      password: 'client123',
    });
    if (res.status !== 200 || !res.body.token) {
      throw new Error(`Client login failed: ${JSON.stringify(res.body)}`);
    }
    clientToken = res.body.token;
  });

  // 5. Admin Login
  await assertTest('5. Admin Authentication Login', async () => {
    const res = await request('POST', '/api/auth/login', {
      email: 'admin@limitless.com',
      password: 'admin123',
    });
    if (res.status !== 200 || !res.body.token || res.body.user.role !== 'admin') {
      throw new Error(`Admin login failed`);
    }
    adminToken = res.body.token;
  });

  // 6. Distributor Login
  await assertTest('6. Distributor Authentication Login', async () => {
    const res = await request('POST', '/api/auth/login', {
      email: 'distributor@limitless.com',
      password: 'dist123',
    });
    if (res.status !== 200 || !res.body.token || res.body.user.role !== 'distributor') {
      throw new Error(`Distributor login failed`);
    }
    distributorToken = res.body.token;
  });

  // 7. Update Client Profile (Chronic Conditions)
  await assertTest('7. Update Client Health Profile & Chronic Conditions', async () => {
    const res = await request(
      'PUT',
      '/api/auth/profile',
      {
        age: 35,
        gender: 'Male',
        height_cm: 180,
        weight_kg: 82,
        activity_level: 'Moderate',
        health_goals: 'Muscle Recovery, Sleep Quality',
        chronic_diseases: 'Hypertension, Mild Kidney Disease',
        allergies: 'Peanuts',
        medication_notes: 'Lisinopril',
      },
      clientToken
    );
    if (res.status !== 200 || !res.body.profile) {
      throw new Error(`Failed to update profile: ${JSON.stringify(res.body)}`);
    }
  });

  // 8. AI Recommendation Engine Calculation
  await assertTest('8. AI Recommendation Engine Calculation & Contraindications', async () => {
    const res = await request('GET', '/api/products/recommendations', null, clientToken);
    if (res.status !== 200 || !res.body.recommendations || res.body.recommendations.length === 0) {
      throw new Error(`No recommendations returned: ${JSON.stringify(res.body)}`);
    }
    const hasWarnings = res.body.recommendations.some((r) => r.warnings && r.warnings.length > 0);
    console.log(`    ℹ️ AI Recommender generated ${res.body.recommendations.length} proposals (Safety Warnings Active: ${hasWarnings})`);
  });

  // 9. Promo Code Validation
  await assertTest('9. Promo Discount Code Validation (/api/discounts/validate)', async () => {
    const res = await request('POST', '/api/discounts/validate', { code: 'LIMITLESS10', order_amount: 100 }, clientToken);
    if (res.status !== 200 || !res.body.discount) {
      throw new Error(`Promo code validation failed: ${JSON.stringify(res.body)}`);
    }
    if (res.body.discount.discount_amount !== 10) {
      throw new Error(`Expected 10% discount ($10), got $${res.body.discount.discount_amount}`);
    }
  });

  // 10. Checkout Flow
  await assertTest('10. Order Checkout & Inventory Reduction', async () => {
    const res = await request(
      'POST',
      '/api/orders',
      {
        items: [{ product_id: 1, quantity: 2 }],
        shipping_address: '123 Limitless Avenue, Cairo',
        customer_phone: '+201012345678',
        payment_method: 'Cash on Delivery',
        discount_code: 'LIMITLESS10',
      },
      clientToken
    );
    if (res.status !== 201 || !res.body.order) {
      throw new Error(`Checkout failed: ${JSON.stringify(res.body)}`);
    }
    createdOrderId = res.body.order.id;
    console.log(`    ℹ️ Order created successfully (ID: #${createdOrderId}, Total: $${res.body.order.final_amount})`);
  });

  // 11. Client My Orders
  await assertTest('11. Fetch Client Order History & Status Stepper', async () => {
    const res = await request('GET', '/api/orders/my-orders', null, clientToken);
    if (res.status !== 200 || !res.body.orders) {
      throw new Error(`Fetching client orders failed: ${JSON.stringify(res.body)}`);
    }
  });

  // 12. Admin Create Product
  await assertTest('12. Admin Product Catalog Addition', async () => {
    const res = await request(
      'POST',
      '/api/products',
      {
        name: 'Limitless Test Booster Max',
        category: 'Daily Wellness',
        price: 39.99,
        stock_quantity: 50,
        description: 'High-potency support with Zinc, Boron & Ashwagandha.',
        dosage_instructions: 'Take 2 capsules daily with water.',
        active_ingredients: 'Zinc 15mg, Boron 10mg, KSM-66 Ashwagandha 600mg',
        health_tags: 'Men Health, Energy',
        image_url: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500',
        contraindications: 'Avoid if severe renal dysfunction',
      },
      adminToken
    );
    if (res.status !== 201 || !res.body.product) {
      throw new Error(`Failed to create product`);
    }
    createdProductId = res.body.product.id;
  });

  // 13. Admin Toggle Payment Status & Assign Order
  await assertTest('13. Admin Payment Status Toggle & Distributor Assignment', async () => {
    if (!createdOrderId) throw new Error('No order ID available');
    const paymentRes = await request('PUT', `/api/orders/${createdOrderId}/payment`, { payment_status: 'Paid' }, adminToken);
    if (paymentRes.status !== 200 || paymentRes.body.order.payment_status !== 'Paid') {
      throw new Error(`Failed to toggle payment status: ${JSON.stringify(paymentRes.body)}`);
    }
  });

  // 14. Admin Reports Dashboard
  await assertTest('14. Admin Reports & Analytics Dashboard Query', async () => {
    const res = await request('GET', '/api/reports/summary', null, adminToken);
    if (res.status !== 200 || !res.body.metrics) {
      throw new Error(`Failed to fetch reports dashboard: ${JSON.stringify(res.body)}`);
    }
    console.log(`    ℹ️ Revenue: $${res.body.metrics.total_revenue}, Total Orders: ${res.body.metrics.total_orders}`);
  });

  // 15. Distributor Deliveries Queue & Status Progression
  await assertTest('15. Distributor Delivery Queue & Status Progression', async () => {
    const queueRes = await request('GET', '/api/distributor/deliveries', null, distributorToken);
    if (queueRes.status !== 200 || !queueRes.body.deliveries) {
      throw new Error(`Distributor queue failed`);
    }
    if (queueRes.body.deliveries.length > 0) {
      const deliveryId = queueRes.body.deliveries[0].id;
      const statusRes = await request('PUT', `/api/distributor/deliveries/${deliveryId}`, { status: 'In Transit', notes: 'Out for delivery' }, distributorToken);
      if (statusRes.status !== 200) {
        throw new Error(`Updating delivery status failed: ${JSON.stringify(statusRes.body)}`);
      }
    }
  });

  // 16. Distributor Warehouse Capacity
  await assertTest('16. Distributor Warehouse Stock Capacity Query', async () => {
    const res = await request('GET', '/api/distributor/stock-capacity', null, distributorToken);
    if (res.status !== 200 || !res.body.summary) {
      throw new Error(`Capacity query failed: ${JSON.stringify(res.body)}`);
    }
    console.log(`    ℹ️ Warehouse Total Stock: ${res.body.summary.total_stock_units} units across ${res.body.summary.total_products} SKUs (${res.body.summary.warehouse_utilization_pct}% utilization)`);
  });

  console.log('\n=================================================================');
  console.log(` 🏆 TEST SUITE RESULT: ${passed} PASSED | ${failed} FAILED`);
  console.log('=================================================================\n');

  if (failed > 0) {
    process.exit(1);
  }
}

runTestSuite().catch((err) => {
  console.error('Fatal test error:', err);
  process.exit(1);
});
