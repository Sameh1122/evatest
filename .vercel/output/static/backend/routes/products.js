const express = require('express');
const { dbData, saveDb, getNextId } = require('../database');
const { verifyToken, requireRoles, optionalAuth } = require('../middleware/auth');

const router = express.Router();

// Get all products with search & filters
router.get('/', (req, res) => {
  let { search, category, health_tag, min_price, max_price, is_featured } = req.query;

  let results = dbData.products.filter(p => p.is_active == 1 || p.is_active === true || req.query.include_inactive === 'true');

  if (search) {
    const q = search.toLowerCase();
    results = results.filter(p => {
      const name = String(p.name || '').toLowerCase();
      const desc = String(p.description || '').toLowerCase();
      const cat = String(p.category || '').toLowerCase();
      const tags = Array.isArray(p.health_tags) ? p.health_tags.join(' ').toLowerCase() : String(p.health_tags || '').toLowerCase();
      return name.includes(q) || desc.includes(q) || cat.includes(q) || tags.includes(q);
    });
  }

  if (category && category !== 'All') {
    results = results.filter(p => String(p.category || '').toLowerCase() === category.toLowerCase());
  }

  if (health_tag) {
    results = results.filter(p => {
      const tags = Array.isArray(p.health_tags) ? p.health_tags.join(' ').toLowerCase() : String(p.health_tags || '').toLowerCase();
      return tags.includes(health_tag.toLowerCase());
    });
  }

  if (min_price) {
    results = results.filter(p => p.price >= parseFloat(min_price));
  }

  if (max_price) {
    results = results.filter(p => p.price <= parseFloat(max_price));
  }

  if (is_featured === 'true' || is_featured === '1') {
    results = results.filter(p => p.is_featured === 1 || p.is_featured === true);
  }

  res.json({
    count: results.length,
    products: results
  });
});

// Smart AI / Rule-based Recommendation Engine based on Client Profile & Chronic Diseases
router.get('/recommendations', optionalAuth, (req, res) => {
  let userProfile = null;
  if (req.user) {
    userProfile = dbData.client_profiles.find(p => p.user_id === req.user.id);
  }

  // If visitor or no profile, use fallback query params or default wellness recommendations
  const chronicDiseases = userProfile ? (userProfile.chronic_diseases || '') : (req.query.chronic_diseases || '');
  const healthGoals = userProfile ? (userProfile.health_goals || '') : (req.query.health_goals || 'General Wellness');

  const products = dbData.products.filter(p => p.is_active == 1 || p.is_active === true);
  const recommendations = [];

  for (const product of products) {
    let score = 0;
    let matchReasons = [];
    let warnings = [];

    const pTags = Array.isArray(product.health_tags) ? product.health_tags.join(' ').toLowerCase() : String(product.health_tags || '').toLowerCase();
    const pContra = Array.isArray(product.contraindications) ? product.contraindications.join(' ').toLowerCase() : String(product.contraindications || '').toLowerCase();
    const cDiseases = String(chronicDiseases).toLowerCase();
    const goals = String(healthGoals).toLowerCase();

    // 1. Goal matching
    if (goals.includes('heart') && (pTags.includes('heart') || pTags.includes('cardio'))) {
      score += 30;
      matchReasons.push('Supports Cardiovascular & Heart Health');
    }
    if (goals.includes('joint') && (pTags.includes('joint') || pTags.includes('pain'))) {
      score += 30;
      matchReasons.push('Improves Joint Mobility & Flexibility');
    }
    if (goals.includes('muscle') && (pTags.includes('muscle') || pTags.includes('recovery'))) {
      score += 25;
      matchReasons.push('Promotes Muscle Recovery & Synthesis');
    }
    if (goals.includes('sleep') && (pTags.includes('sleep') || pTags.includes('relax'))) {
      score += 25;
      matchReasons.push('Enhances Restful Sleep & Relaxation');
    }
    if (goals.includes('immune') && (pTags.includes('immune') || pTags.includes('bone'))) {
      score += 25;
      matchReasons.push('Boosts Immune System Defense');
    }

    // 2. Chronic disease contraindication check & safety warnings
    if (cDiseases.includes('hypertension') || cDiseases.includes('blood pressure')) {
      if (pContra.includes('blood pressure') || pContra.includes('anticoagulant') || pContra.includes('bleeding')) {
        warnings.push('Caution: May interact with blood pressure or anticoagulant medications.');
        score -= 20;
      }
    }
    if (cDiseases.includes('kidney') || cDiseases.includes('renal')) {
      if (pContra.includes('kidney') || pContra.includes('renal')) {
        warnings.push('Warning: Not advised for severe kidney conditions.');
        score -= 50;
      }
    }
    if (cDiseases.includes('autoimmune')) {
      if (pContra.includes('autoimmune')) {
        warnings.push('Warning: Stimulates immune system; caution in autoimmune conditions.');
        score -= 40;
      }
    }

    if (product.is_featured) {
      score += 10;
    }

    recommendations.push({
      product,
      score,
      matchReasons,
      warnings
    });
  }

  // Sort by recommendation score descending
  recommendations.sort((a, b) => b.score - a.score);

  res.json({
    client_profile: userProfile,
    chronic_diseases_detected: chronicDiseases || 'None reported',
    health_goals_targeted: healthGoals,
    recommendations: recommendations.slice(0, 6)
  });
});

// Get product details by ID or Slug
router.get('/:idOrSlug', (req, res) => {
  const param = req.params.idOrSlug;
  const product = dbData.products.find(p => p.id.toString() === param || p.slug === param);

  if (!product) {
    return res.status(404).json({ error: 'Product not found.' });
  }

  res.json({ product });
});

// Admin: Add Product
router.post('/', verifyToken, requireRoles(['admin']), (req, res) => {
  const {
    name,
    description,
    category,
    price,
    stock_quantity,
    dosage_instructions,
    image_url,
    health_tags,
    contraindications,
    active_ingredients,
    is_featured
  } = req.body;

  if (!name || !category || price === undefined) {
    return res.status(400).json({ error: 'Name, category, and price are required.' });
  }

  const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '') + '-' + Date.now();

  const newProduct = {
    id: getNextId('products'),
    name,
    slug,
    description: description || '',
    category,
    price: parseFloat(price),
    stock_quantity: parseInt(stock_quantity || 0, 10),
    dosage_instructions: dosage_instructions || '',
    image_url: image_url || 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
    health_tags: health_tags || '',
    contraindications: contraindications || '',
    active_ingredients: active_ingredients || '',
    is_featured: is_featured ? 1 : 0,
    is_active: 1,
    created_at: new Date().toISOString()
  };

  dbData.products.push(newProduct);
  saveDb();

  res.status(201).json({
    message: 'Product created successfully',
    product: newProduct
  });
});

// Admin: Edit Product
router.put('/:id', verifyToken, requireRoles(['admin', 'distributor']), (req, res) => {
  const productId = parseInt(req.params.id, 10);
  const index = dbData.products.findIndex(p => p.id === productId);

  if (index === -1) {
    return res.status(404).json({ error: 'Product not found.' });
  }

  const p = dbData.products[index];
  const body = req.body;

  if (body.name !== undefined) p.name = body.name;
  if (body.description !== undefined) p.description = body.description;
  if (body.category !== undefined) p.category = body.category;
  if (body.price !== undefined) p.price = parseFloat(body.price);
  if (body.stock_quantity !== undefined) p.stock_quantity = parseInt(body.stock_quantity, 10);
  if (body.dosage_instructions !== undefined) p.dosage_instructions = body.dosage_instructions;
  if (body.image_url !== undefined) p.image_url = body.image_url;
  if (body.health_tags !== undefined) p.health_tags = body.health_tags;
  if (body.contraindications !== undefined) p.contraindications = body.contraindications;
  if (body.active_ingredients !== undefined) p.active_ingredients = body.active_ingredients;
  if (body.is_featured !== undefined) p.is_featured = body.is_featured ? 1 : 0;
  if (body.is_active !== undefined) p.is_active = body.is_active ? 1 : 0;

  saveDb();

  res.json({
    message: 'Product updated successfully',
    product: p
  });
});

// Admin: Delete/Archive Product
router.delete('/:id', verifyToken, requireRoles(['admin']), (req, res) => {
  const productId = parseInt(req.params.id, 10);
  const index = dbData.products.findIndex(p => p.id === productId);

  if (index === -1) {
    return res.status(404).json({ error: 'Product not found.' });
  }

  // Soft delete (archive)
  dbData.products[index].is_active = 0;
  saveDb();

  res.json({ message: 'Product archived successfully.' });
});

module.exports = router;
