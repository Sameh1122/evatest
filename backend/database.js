const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

const dbFilePath = path.join(__dirname, 'nutripulse_db.json');

let dbData = {
  users: [],
  client_profiles: [],
  products: [],
  discounts: [],
  orders: [],
  order_items: [],
  deliveries: [],
  favorites: [],
  cart_items: []
};

function saveDb() {
  try {
    fs.writeFileSync(dbFilePath, JSON.stringify(dbData, null, 2), 'utf8');
  } catch (err) {
    console.error('Failed to save database to file:', err);
  }
}

function loadDb() {
  seedData(); // Fresh re-seed with shop.limitlessnaturals.com dataset
}

function getNextId(collectionName) {
  const items = dbData[collectionName] || [];
  if (items.length === 0) return 1;
  const maxId = Math.max(...items.map(item => item.id || 0));
  return maxId + 1;
}

function seedData() {
  console.log('Seeding shop.limitlessnaturals.com dataset...');
  dbData.users.length = 0;
  dbData.client_profiles.length = 0;
  dbData.products.length = 0;
  dbData.discounts.length = 0;
  dbData.orders.length = 0;
  dbData.order_items.length = 0;
  dbData.deliveries.length = 0;
  dbData.favorites.length = 0;
  dbData.cart_items.length = 0;

  const salt = bcrypt.genSaltSync(10);
  const adminHash = bcrypt.hashSync('admin123', salt);
  const distHash = bcrypt.hashSync('dist123', salt);
  const clientHash = bcrypt.hashSync('client123', salt);

  const now = new Date().toISOString();
  // Users
  dbData.users.push(
    {
      id: 1,
      name: 'Shop Limitless Admin',
      email: 'admin@limitless.com',
      password_hash: adminHash,
      role: 'admin',
      phone: '+20 100 123 4567',
      created_at: now
    },
    {
      id: 2,
      name: 'Eva Logistics Distributor',
      email: 'distributor@limitless.com',
      password_hash: distHash,
      role: 'distributor',
      phone: '+20 100 987 6543',
      created_at: now
    },
    {
      id: 3,
      name: 'Karim Hassan (Client)',
      email: 'client@limitless.com',
      password_hash: clientHash,
      role: 'client',
      phone: '+20 111 222 3333',
      created_at: now
    }
  );

  // Client Profile
  dbData.client_profiles.push({
    id: 1,
    user_id: 3,
    age: 32,
    gender: 'Male',
    height_cm: 180,
    weight_kg: 78,
    activity_level: 'Moderate',
    health_goals: 'Hydration & Balance, Heart Health, Muscle Recovery',
    chronic_diseases: 'Hypertension, Mild Kidney Disease',
    allergies: 'Seafood',
    medication_notes: 'Takes daily ACE inhibitor for blood pressure',
    updated_at: now
  });

  // Official Shop Limitless Catalog
  dbData.products.push(
    {
      id: 1,
      name: 'Limitless Man Max Multivitamin 30 Tabs',
      slug: 'limitless-man-max-30',
      description: 'The ultimate daily wellness supplement for men by Eva Pharma, featuring 26 vitamins, minerals, Ginseng & CoQ10 to support energy, immunity, stamina, and cardiovascular health.',
      category: 'Daily Wellness',
      price: 11.99,
      stock_quantity: 160,
      dosage_instructions: 'Take 1 tablet daily with food.',
      image_url: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Men Health, Energy, Stamina, Immune Defense',
      contraindications: 'Severe uncontrolled hypertension without physician consultation',
      active_ingredients: '26 Vitamins & Minerals, Panax Ginseng 50mg, CoQ10 10mg, Lycopene',
      is_featured: 1,
      is_active: 1,
      created_at: now
    },
    {
      id: 2,
      name: 'Limitless Woman Max Multivitamin 30 Tabs',
      slug: 'limitless-woman-max-30',
      description: 'Specially engineered multivitamin & beauty matrix for women, packed with Hydrolyzed Collagen, Biotin, Folic Acid, Iron, and Zinc for radiant hair, skin, nails, and bone strength.',
      category: 'Daily Wellness',
      price: 11.99,
      stock_quantity: 140,
      dosage_instructions: 'Take 1 tablet daily after meal.',
      image_url: 'https://images.unsplash.com/photo-1577401239170-897942555fb3?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Women Health, Hair Skin Nails, Bone Health, Vitality',
      contraindications: 'Hemochromatosis (iron overload condition)',
      active_ingredients: 'Hydrolyzed Marine Collagen 100mg, Biotin 1000mcg, Iron 18mg, Folic Acid 400mcg',
      is_featured: 1,
      is_active: 1,
      created_at: now
    },
    {
      id: 3,
      name: 'Limitless Omega-3 Fish Oil 2000mg',
      slug: 'limitless-omega-3-2000mg',
      description: 'High-purity molecularly distilled EPA & DHA softgels for heart health, joint flexibility, cognitive clarity, and cholesterol balance.',
      category: 'Full-Body Support',
      price: 14.99,
      stock_quantity: 190,
      dosage_instructions: 'Take 2 softgels daily with lunch or dinner.',
      image_url: 'https://images.unsplash.com/photo-1550572017-edd951aa8f72?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Heart Health, Joint Flexibility, Brain & Eye, Cholesterol',
      contraindications: 'Bleeding disorders, Anticoagulant / Blood-thinning drugs',
      active_ingredients: 'Pure Fish Oil 2000mg (EPA 720mg, DHA 480mg)',
      is_featured: 1,
      is_active: 1,
      created_at: now
    },
    {
      id: 4,
      name: 'Limitless Hydration Electrolytes 14 Packets',
      slug: 'limitless-hydration-electrolytes',
      description: 'Advanced cellular hydration mix formulated with Sodium, Potassium, Magnesium, and Vitamin C for rapid fluid replenishment and muscle cramp prevention.',
      category: 'Hydration & Balance',
      price: 10.50,
      stock_quantity: 220,
      dosage_instructions: 'Mix 1 stick packet into 16 oz of cold water.',
      image_url: 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Hydration, Electrolytes, Energy, Anti-Fatigue',
      contraindications: 'Severe End-Stage Renal Disease (Potassium restriction)',
      active_ingredients: 'Sodium 500mg, Potassium 380mg, Magnesium 100mg, Vitamin C 250mg',
      is_featured: 1,
      is_active: 1,
      created_at: now
    },
    {
      id: 5,
      name: 'Limitless Vitamin C 1000mg Effervescent',
      slug: 'limitless-vitamin-c-effervescent',
      description: 'Rapid-absorbing effervescent immune shield with 1000mg Vitamin C and Zinc to support immune response and collagen synthesis.',
      category: 'Immune Defense',
      price: 7.50,
      stock_quantity: 250,
      dosage_instructions: 'Dissolve 1 tablet in water daily.',
      image_url: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Immune Defense, Antioxidant, Vitality',
      contraindications: 'Oxalate Kidney Stones history',
      active_ingredients: 'Vitamin C (Ascorbic Acid) 1000mg, Zinc 15mg',
      is_featured: 0,
      is_active: 1,
      created_at: now
    },
    {
      id: 6,
      name: 'Limitless Lactoferrin 100mg Immunity',
      slug: 'limitless-lactoferrin-100mg',
      description: 'Bio-active iron-binding protein formula supporting immune cell defense, gut mucosal integrity, and healthy iron metabolism.',
      category: 'Immune Defense',
      price: 18.50,
      stock_quantity: 75,
      dosage_instructions: 'Take 1 sachet daily before breakfast.',
      image_url: 'https://images.unsplash.com/photo-1616671285420-a68132e4860b?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Immune Defense, Iron Absorption, Gut Integrity',
      contraindications: 'Severe Dairy Protein Allergy',
      active_ingredients: 'Bovine Lactoferrin 100mg, Vitamin C 50mg',
      is_featured: 1,
      is_active: 1,
      created_at: now
    },
    {
      id: 7,
      name: 'Limitless Collagen Max Marine 30 Sachets',
      slug: 'limitless-collagen-max',
      description: 'Hydrolyzed Marine Collagen peptides combined with Hyaluronic Acid & Vitamin C for smooth skin elasticity and joint cartilage rebuilding.',
      category: 'Full-Body Support',
      price: 21.99,
      stock_quantity: 12, // Low stock reorder alert!
      dosage_instructions: 'Mix 1 sachet in warm or cold beverage daily.',
      image_url: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Joint Mobility, Anti-Aging, Skin Elasticity',
      contraindications: 'Fish or Marine Allergy',
      active_ingredients: 'Hydrolyzed Marine Collagen 5000mg, Hyaluronic Acid 100mg, Vitamin C 80mg',
      is_featured: 1,
      is_active: 1,
      created_at: now
    },
    {
      id: 8,
      name: 'Limitless Magnesium Citrate 400mg',
      slug: 'limitless-magnesium-citrate',
      description: 'Gentle, high-solubility magnesium for deep muscle relaxation, cramp prevention, and nervous system calm.',
      category: 'Full-Body Support',
      price: 9.99,
      stock_quantity: 175,
      dosage_instructions: 'Take 2 capsules before bedtime.',
      image_url: 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=600&auto=format&fit=crop&q=80',
      health_tags: 'Muscle Relaxation, Sleep Quality, Nerve Support',
      contraindications: 'Severe Kidney Failure',
      active_ingredients: 'Elemental Magnesium (as Citrate) 400mg',
      is_featured: 0,
      is_active: 1,
      created_at: now
    }
  );

  // Discounts
  dbData.discounts.push(
    {
      id: 1,
      code: 'LIMITLESS10',
      description: '10% discount on all Shop Limitless orders',
      discount_type: 'percentage',
      discount_value: 10,
      min_order_amount: 15,
      times_used: 3,
      starts_at: now,
      expires_at: '2026-12-31T23:59:59.000Z',
      is_active: 1
    },
    {
      id: 2,
      code: 'HYDRATE20',
      description: '20% off orders above \$30',
      discount_type: 'percentage',
      discount_value: 20,
      min_order_amount: 30,
      times_used: 1,
      starts_at: now,
      expires_at: '2026-12-31T23:59:59.000Z',
      is_active: 1
    }
  );

  // Orders
  dbData.orders.push(
    {
      id: 1,
      order_number: 'LIMITLESS-2026-101',
      user_id: 3,
      total_amount: 37.48,
      discount_amount: 3.75,
      final_amount: 33.73,
      status: 'Out for Delivery',
      payment_status: 'Paid',
      payment_method: 'Credit Card',
      shipping_address: 'Building 14, Smart Village, Giza, Egypt',
      customer_phone: '+20 111 222 3333',
      distributor_id: 2,
      created_at: now,
      updated_at: now
    }
  );

  dbData.order_items.push(
    {
      id: 1,
      order_id: 1,
      product_id: 1,
      product_name: 'Limitless Man Max Multivitamin 30 Tabs',
      price: 11.99,
      quantity: 1,
      subtotal: 11.99
    },
    {
      id: 2,
      order_id: 1,
      product_id: 3,
      product_name: 'Limitless Omega-3 Fish Oil 2000mg',
      price: 14.99,
      quantity: 1,
      subtotal: 14.99
    },
    {
      id: 3,
      order_id: 1,
      product_id: 4,
      product_name: 'Limitless Hydration Electrolytes 14 Packets',
      price: 10.50,
      quantity: 1,
      subtotal: 10.50
    }
  );

  dbData.deliveries.push(
    {
      id: 1,
      order_id: 1,
      distributor_id: 2,
      status: 'Out for Delivery',
      delivery_address: 'Building 14, Smart Village, Giza, Egypt',
      notes: 'Express courier delivery',
      updated_at: now
    }
  );

  saveDb();
}

// Initial boot
loadDb();

module.exports = {
  dbData,
  saveDb,
  getNextId
};
