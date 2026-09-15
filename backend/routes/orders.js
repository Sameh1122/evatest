const express = require('express');
const { dbData, saveDb, getNextId } = require('../database');
const { verifyToken, requireRoles } = require('../middleware/auth');

const router = express.Router();

// Create Order (Checkout)
router.post('/', verifyToken, (req, res) => {
  const {
    items,
    shipping_address,
    customer_phone,
    payment_method = 'Cash on Delivery',
    discount_code
  } = req.body;

  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'Cart is empty. Please add products to check out.' });
  }

  if (!shipping_address) {
    return res.status(400).json({ error: 'Shipping address is required.' });
  }

  let totalAmount = 0;
  const orderItemsData = [];

  // Verify stock & calculate total
  for (const item of items) {
    const product = dbData.products.find(p => p.id === item.product_id);
    if (!product || product.is_active !== 1) {
      return res.status(400).json({ error: `Product ID ${item.product_id} is no longer available.` });
    }

    if (product.stock_quantity < item.quantity) {
      return res.status(400).json({
        error: `Insufficient stock for '${product.name}'. Requested: ${item.quantity}, Available: ${product.stock_quantity}.`
      });
    }

    const subtotal = product.price * item.quantity;
    totalAmount += subtotal;

    orderItemsData.push({
      product_id: product.id,
      product_name: product.name,
      price: product.price,
      quantity: item.quantity,
      subtotal: parseFloat(subtotal.toFixed(2))
    });

    // Deduct stock
    product.stock_quantity -= item.quantity;
  }

  // Calculate discount
  let discountAmount = 0;
  if (discount_code) {
    const promo = dbData.discounts.find(
      d => d.code.toUpperCase() === discount_code.trim().toUpperCase() && d.is_active === 1
    );
    if (promo && totalAmount >= promo.min_order_amount) {
      if (promo.discount_type === 'percentage') {
        discountAmount = (totalAmount * promo.discount_value) / 100;
      } else {
        discountAmount = Math.min(totalAmount, promo.discount_value);
      }
      promo.times_used += 1;
    }
  }

  const finalAmount = Math.max(0, totalAmount - discountAmount);

  // Auto assign to available distributor
  const distributor = dbData.users.find(u => u.role === 'distributor') || null;

  const orderId = getNextId('orders');
  const orderNumber = `NP-2026-${Math.floor(1000 + Math.random() * 9000)}`;
  const now = new Date().toISOString();

  const newOrder = {
    id: orderId,
    order_number: orderNumber,
    user_id: req.user.id,
    total_amount: parseFloat(totalAmount.toFixed(2)),
    discount_amount: parseFloat(discountAmount.toFixed(2)),
    final_amount: parseFloat(finalAmount.toFixed(2)),
    status: 'Pending',
    payment_status: payment_method === 'Credit Card' ? 'Paid' : 'Pending',
    payment_method,
    shipping_address,
    customer_phone: customer_phone || req.user.phone || '',
    distributor_id: distributor ? distributor.id : null,
    created_at: now,
    updated_at: now
  };

  dbData.orders.push(newOrder);

  // Create Order Items
  for (const oi of orderItemsData) {
    dbData.order_items.push({
      id: getNextId('order_items'),
      order_id: orderId,
      ...oi
    });
  }

  // Create Delivery Record
  if (distributor) {
    dbData.deliveries.push({
      id: getNextId('deliveries'),
      order_id: orderId,
      distributor_id: distributor.id,
      status: 'Assigned',
      delivery_address: shipping_address,
      notes: 'Standard delivery dispatch',
      updated_at: now
    });
  }

  // Clear user cart
  dbData.cart_items = dbData.cart_items.filter(c => c.user_id !== req.user.id);

  saveDb();

  res.status(201).json({
    message: 'Order placed successfully!',
    order: newOrder,
    items: orderItemsData
  });
});

// Client: Get My Orders
router.get('/my-orders', verifyToken, (req, res) => {
  const userOrders = dbData.orders
    .filter(o => o.user_id === req.user.id)
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

  const result = userOrders.map(order => {
    const items = dbData.order_items.filter(oi => oi.order_id === order.id);
    const delivery = dbData.deliveries.find(d => d.order_id === order.id) || null;
    return {
      ...order,
      items,
      delivery
    };
  });

  res.json({ orders: result });
});

// Admin: Get All Orders (With Filters)
router.get('/', verifyToken, requireRoles(['admin']), (req, res) => {
  const { status, payment_status, search } = req.query;

  let results = [...dbData.orders];

  if (status) {
    results = results.filter(o => o.status.toLowerCase() === status.toLowerCase());
  }

  if (payment_status) {
    results = results.filter(o => o.payment_status.toLowerCase() === payment_status.toLowerCase());
  }

  if (search) {
    const q = search.toLowerCase();
    results = results.filter(o =>
      o.order_number.toLowerCase().includes(q) ||
      o.shipping_address.toLowerCase().includes(q) ||
      (o.customer_phone && o.customer_phone.includes(q))
    );
  }

  results.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

  const fullOrders = results.map(order => {
    const items = dbData.order_items.filter(oi => oi.order_id === order.id);
    const customer = dbData.users.find(u => u.id === order.user_id) || { name: 'Unknown', email: '' };
    const distributor = dbData.users.find(u => u.id === order.distributor_id) || null;
    const delivery = dbData.deliveries.find(d => d.order_id === order.id) || null;
    return {
      ...order,
      customer_name: customer.name,
      customer_email: customer.email,
      distributor_name: distributor ? distributor.name : 'Unassigned',
      items,
      delivery
    };
  });

  res.json({ orders: fullOrders });
});

// Update Order Status (Admin or Distributor)
router.put('/:id/status', verifyToken, requireRoles(['admin', 'distributor']), (req, res) => {
  const orderId = parseInt(req.params.id, 10);
  const { status, distributor_id } = req.body;

  const orderIndex = dbData.orders.findIndex(o => o.id === orderId);
  if (orderIndex === -1) {
    return res.status(404).json({ error: 'Order not found.' });
  }

  const order = dbData.orders[orderIndex];
  if (status) {
    const validStatuses = ['Pending', 'Processing', 'Out for Delivery', 'Delivered', 'Cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: `Invalid status. Must be one of: ${validStatuses.join(', ')}` });
    }
    order.status = status;
  }

  if (distributor_id !== undefined) {
    order.distributor_id = parseInt(distributor_id, 10);
  }

  order.updated_at = new Date().toISOString();

  // Also update delivery status
  let delivery = dbData.deliveries.find(d => d.order_id === orderId);
  if (!delivery && order.distributor_id) {
    delivery = {
      id: getNextId('deliveries'),
      order_id: orderId,
      distributor_id: order.distributor_id,
      status: order.status,
      delivery_address: order.shipping_address,
      notes: '',
      updated_at: new Date().toISOString()
    };
    dbData.deliveries.push(delivery);
  } else if (delivery) {
    delivery.status = order.status;
    if (order.distributor_id) delivery.distributor_id = order.distributor_id;
    delivery.updated_at = new Date().toISOString();
  }

  saveDb();

  res.json({
    message: 'Order status updated successfully',
    order,
    delivery
  });
});

// Admin: Toggle Payment Status (Include/Exclude Payment)
router.put('/:id/payment', verifyToken, requireRoles(['admin']), (req, res) => {
  const orderId = parseInt(req.params.id, 10);
  const { payment_status } = req.body;

  const orderIndex = dbData.orders.findIndex(o => o.id === orderId);
  if (orderIndex === -1) {
    return res.status(404).json({ error: 'Order not found.' });
  }

  const order = dbData.orders[orderIndex];
  if (payment_status) {
    order.payment_status = payment_status;
  } else {
    // Toggle
    order.payment_status = order.payment_status === 'Paid' ? 'Pending' : 'Paid';
  }

  order.updated_at = new Date().toISOString();
  saveDb();

  res.json({
    message: 'Payment status updated successfully',
    order
  });
});

module.exports = router;
