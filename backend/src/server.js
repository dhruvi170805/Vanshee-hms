require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const { initDatabase, getDriver } = require('./config/database');
const { createSchema } = require('./db/schema');
const { seedData } = require('./db/seed');
const { registerModules } = require('./modules/registry');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Root info route
// app.get('/', (req, res) => {
//   res.json({
//     message: 'Hospital Management System (HMS) REST API Backend',
//     status: 'ONLINE',
//     endpoints: {
//       health: '/health',
//       dashboard: '/api/v1/dashboard/stats',
//       classifications: '/api/v1/classification',
//       medicines: '/api/v1/medicine'
//     },
//     note: 'To open the visual web dashboard UI, start the Flutter frontend in your second terminal!'
//   });
// });

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'UP',
    service: 'Hospital Management System API',
    database_driver: getDriver(),
    timestamp: new Date().toISOString()
  });
});

async function startServer() {
  try {
    // Initialize Database
    await initDatabase();

    // Ensure tables exist
    await createSchema();

    // Seed initial data if empty
    await seedData();

    // Dynamically Register Feature Modules (/api/v1/dashboard, /api/v1/classification, /api/v1/medicine, etc.)
    registerModules(app, '/api/v1');
    // Serve the Flutter web frontend
    const frontendPath = path.join(__dirname, '../../frontend-build');

    app.use(express.static(frontendPath));

    // Flutter web route fallback
    app.get('*', (req, res, next) => {
      if (req.path.startsWith('/api/') || req.path === '/health') {
        return next();
      }

      res.sendFile(path.join(frontendPath, 'index.html'), (err) => {
        if (err) next(err);
      });
    });

    // 404 Route handler
    app.use((req, res) => {
      res.status(404).json({ success: false, error: `Route ${req.originalUrl} not found` });
    });

    // Global Error Handler
    app.use((err, req, res, next) => {
      console.error('Unhandled Error:', err);
      res.status(500).json({ success: false, error: 'Internal Server Error', details: err.message });
    });

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error('❌ Failed to start HMS Backend server:', err);
    process.exit(1);
  }
}

startServer();
