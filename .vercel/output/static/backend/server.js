const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/products');
const discountRoutes = require('./routes/discounts');
const orderRoutes = require('./routes/orders');
const distributorRoutes = require('./routes/distributor');
const reportRoutes = require('./routes/reports');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/discounts', discountRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/distributor', distributorRoutes);
app.use('/api/reports', reportRoutes);

// System Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'NutriPulse Health Supplement E-Commerce API',
    timestamp: new Date().toISOString()
  });
});

// Serve Flutter Web app static build if available
const webBuildPath = path.join(__dirname, '../frontend/build/web');
app.use(express.static(webBuildPath));

app.get('*', (req, res) => {
  if (req.path.startsWith('/api')) {
    return res.status(404).json({ error: 'API endpoint not found' });
  }
  const indexPath = path.join(webBuildPath, 'index.html');
  if (require('fs').existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.send(`
      <!語html>
      <html>
        <head><title>NutriPulse API Server</title></head>
        <body style="background:#0f172a; color:#fff; font-family:sans-serif; padding:40px;">
          <h1 style="color:#10b981;">NutriPulse API Server is Running!</h1>
          <p>Health Check: <a style="color:#06b6d4;" href="/api/health">/api/health</a></p>
          <p>Flutter Web app is building...</p>
        </body>
      </html>
    `);
  }
});

if (!process.env.VERCEL) {
  app.listen(PORT, () => {
    console.log(`=======================================================`);
    console.log(` NutriPulse Supplement API Server running on port ${PORT}`);
    console.log(` Web App & API available at: http://localhost:${PORT}`);
    console.log(`=======================================================`);
  });
}

module.exports = app;
