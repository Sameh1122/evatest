const express = require('express');
const { dbData, saveDb } = require('../database');
const { verifyToken, requireRoles } = require('../middleware/auth');

const router = express.Router();

// Get Distributor Assigned Deliveries
router.get('/deliveries', verifyToken, requireRoles(['distributor', 'admin']), (req, res) => {
  let deliveries = dbData.deliveries;

  // Filter if logged in as distributor
  if (req.user.role === 'distributor') {
    deliveries = deliveries.filter(d => d.distributor_id === req.user.id);
  }

  const detailedDeliveries = deliveries.map(delivery => {
    const order = dbData.orders.find(o => o.id === delivery.order_id) || {};
    const items = dbData.order_items.filter(oi => oi.order_id === delivery.order_id);
    const customer = dbData.users.find(u => u.id === order.user_id) || { name: 'Customer', phone: '' };

    return {
      ...delivery,
      order_number: order.order_number,
      order_status: order.status,
      payment_status: order.payment_status,
      payment_method: order.payment_method,
      final_amount: order.final_amount,
      customer_name: customer.name,
      customer_phone: order.customer_phone || customer.phone,
      items
    };
  });

  res.json({ deliveries: detailedDeliveries });
});

// Update Delivery Status (Distributor)
router.put('/deliveries/:id', verifyToken, requireRoles(['distributor', 'admin']), (req, res) => {
  const deliveryId = parseInt(req.params.id, 10);
  const { status, notes } = req.body;

  const index = dbData.deliveries.findIndex(d => d.id === deliveryId);
  if (index === -1) {
    return res.status(404).json({ error: 'Delivery record not found.' });
  }

  const delivery = dbData.deliveries[index];
  if (status) {
    delivery.status = status;
    // Update linked order status as well
    const order = dbData.orders.find(o => o.id === delivery.order_id);
    if (order) {
      order.status = status;
      order.updated_at = new Date().toISOString();

      // If marked Delivered & COD, auto mark paid
      if (status === 'Delivered' && order.payment_method === 'Cash on Delivery') {
        order.payment_status = 'Paid';
      }
    }
  }

  if (notes !== undefined) {
    delivery.notes = notes;
  }

  delivery.updated_at = new Date().toISOString();
  saveDb();

  res.json({
    message: 'Delivery status updated successfully',
    delivery
  });
});

// Distributor Stock Capacity View & Inventory Warehouse Levels
router.get('/stock-capacity', verifyToken, requireRoles(['distributor', 'admin']), (req, res) => {
  const products = dbData.products.map(p => {
    let capacityStatus = 'Optimal';
    if (p.stock_quantity <= 15) {
      capacityStatus = 'Low Stock Alert';
    } else if (p.stock_quantity >= 150) {
      capacityStatus = 'High Capacity';
    }

    return {
      id: p.id,
      name: p.name,
      category: p.category,
      stock_quantity: p.stock_quantity,
      max_warehouse_capacity: 250,
      capacity_percentage: Math.min(100, Math.round((p.stock_quantity / 250) * 100)),
      capacity_status: capacityStatus,
      price: p.price
    };
  });

  const totalStock = products.reduce((acc, p) => acc + p.stock_quantity, 0);
  const lowStockCount = products.filter(p => p.stock_quantity <= 15).length;

  res.json({
    summary: {
      total_products: products.length,
      total_stock_units: totalStock,
      low_stock_alerts: lowStockCount,
      warehouse_utilization_pct: Math.round((totalStock / (products.length * 250)) * 100)
    },
    inventory: products
  });
});

module.exports = router;
