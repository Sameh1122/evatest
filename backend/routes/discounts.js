const express = require('express');
const { dbData, saveDb, getNextId } = require('../database');
const { verifyToken, requireRoles } = require('../middleware/auth');

const router = express.Router();

// Validate discount code for customer cart checkout
router.post('/validate', (req, res) => {
  const { code, order_amount } = req.body;

  if (!code) {
    return res.status(400).json({ error: 'Discount code is required.' });
  }

  const subtotal = parseFloat(order_amount || 0);
  const promo = dbData.discounts.find(
    d => d.code.toUpperCase() === code.trim().toUpperCase() && d.is_active === 1
  );

  if (!promo) {
    return res.status(404).json({ error: 'Invalid or expired promo code.' });
  }

  if (promo.expires_at && new Date(promo.expires_at) < new Date()) {
    return res.status(400).json({ error: 'This promo code has expired.' });
  }

  if (subtotal < promo.min_order_amount) {
    return res.status(400).json({
      error: `This coupon requires a minimum order amount of $${promo.min_order_amount.toFixed(2)}.`
    });
  }

  let discountAmount = 0;
  if (promo.discount_type === 'percentage') {
    discountAmount = (subtotal * promo.discount_value) / 100;
  } else {
    discountAmount = Math.min(subtotal, promo.discount_value);
  }

  res.json({
    message: 'Promo code applied successfully!',
    discount: {
      id: promo.id,
      code: promo.code,
      discount_type: promo.discount_type,
      discount_value: promo.discount_value,
      discount_amount: parseFloat(discountAmount.toFixed(2)),
      description: promo.description
    }
  });
});

// Admin: Get all discounts
router.get('/', verifyToken, requireRoles(['admin']), (req, res) => {
  res.json({ discounts: dbData.discounts });
});

// Admin: Create discount
router.post('/', verifyToken, requireRoles(['admin']), (req, res) => {
  const {
    code,
    description,
    discount_type,
    discount_value,
    min_order_amount,
    expires_at
  } = req.body;

  if (!code || !discount_value) {
    return res.status(400).json({ error: 'Code and discount value are required.' });
  }

  const codeUpper = code.trim().toUpperCase();
  const existing = dbData.discounts.find(d => d.code === codeUpper);
  if (existing) {
    return res.status(400).json({ error: 'A discount code with this name already exists.' });
  }

  const newDiscount = {
    id: getNextId('discounts'),
    code: codeUpper,
    description: description || '',
    discount_type: discount_type === 'fixed' ? 'fixed' : 'percentage',
    discount_value: parseFloat(discount_value),
    min_order_amount: parseFloat(min_order_amount || 0),
    times_used: 0,
    starts_at: new Date().toISOString(),
    expires_at: expires_at ? new Date(expires_at).toISOString() : '2026-12-31T23:59:59.000Z',
    is_active: 1
  };

  dbData.discounts.push(newDiscount);
  saveDb();

  res.status(201).json({
    message: 'Discount created successfully',
    discount: newDiscount
  });
});

// Admin: Toggle or Edit discount
router.put('/:id', verifyToken, requireRoles(['admin']), (req, res) => {
  const discountId = parseInt(req.params.id, 10);
  const index = dbData.discounts.findIndex(d => d.id === discountId);

  if (index === -1) {
    return res.status(404).json({ error: 'Discount not found.' });
  }

  const d = dbData.discounts[index];
  const { description, discount_value, min_order_amount, is_active } = req.body;

  if (description !== undefined) d.description = description;
  if (discount_value !== undefined) d.discount_value = parseFloat(discount_value);
  if (min_order_amount !== undefined) d.min_order_amount = parseFloat(min_order_amount);
  if (is_active !== undefined) d.is_active = is_active ? 1 : 0;

  saveDb();

  res.json({
    message: 'Discount updated successfully',
    discount: d
  });
});

// Admin: Delete discount
router.delete('/:id', verifyToken, requireRoles(['admin']), (req, res) => {
  const discountId = parseInt(req.params.id, 10);
  dbData.discounts = dbData.discounts.filter(d => d.id !== discountId);
  saveDb();

  res.json({ message: 'Discount deleted successfully.' });
});

module.exports = router;
