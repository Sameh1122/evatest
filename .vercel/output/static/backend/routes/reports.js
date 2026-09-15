const express = require('express');
const { dbData } = require('../database');
const { verifyToken, requireRoles } = require('../middleware/auth');

const router = express.Router();

router.get('/summary', verifyToken, requireRoles(['admin']), (req, res) => {
  const totalOrders = dbData.orders.length;
  const paidOrders = dbData.orders.filter(o => o.payment_status === 'Paid');
  const totalRevenue = paidOrders.reduce((acc, o) => acc + o.final_amount, 0);
  const pendingRevenue = dbData.orders.filter(o => o.payment_status === 'Pending').reduce((acc, o) => acc + o.final_amount, 0);

  const totalClients = dbData.users.filter(u => u.role === 'client').length;
  const totalProducts = dbData.products.filter(p => p.is_active === 1).length;

  // Category sales breakdown
  const categorySales = {};
  for (const item of dbData.order_items) {
    const product = dbData.products.find(p => p.id === item.product_id);
    const cat = product ? product.category : 'General';
    categorySales[cat] = (categorySales[cat] || 0) + item.subtotal;
  }

  // Top products
  const productSales = {};
  for (const item of dbData.order_items) {
    productSales[item.product_name] = (productSales[item.product_name] || 0) + item.quantity;
  }
  const topProducts = Object.entries(productSales)
    .map(([name, quantity]) => ({ name, quantity }))
    .sort((a, b) => b.quantity - a.quantity)
    .slice(0, 5);

  // Status breakdown
  const statusCounts = {
    Pending: 0,
    Processing: 0,
    'Out for Delivery': 0,
    Delivered: 0,
    Cancelled: 0
  };
  for (const order of dbData.orders) {
    if (statusCounts[order.status] !== undefined) {
      statusCounts[order.status]++;
    }
  }

  // Inventory alert products (<= 15 stock)
  const lowStockItems = dbData.products
    .filter(p => p.stock_quantity <= 15)
    .map(p => ({ id: p.id, name: p.name, stock: p.stock_quantity, category: p.category }));

  res.json({
    metrics: {
      total_revenue: parseFloat(totalRevenue.toFixed(2)),
      pending_revenue: parseFloat(pendingRevenue.toFixed(2)),
      total_orders: totalOrders,
      total_clients: totalClients,
      active_products: totalProducts,
      low_stock_count: lowStockItems.length
    },
    top_products: topProducts,
    sales_by_category: categorySales,
    orders_by_status: statusCounts,
    low_stock_inventory: lowStockItems
  });
});

module.exports = router;
