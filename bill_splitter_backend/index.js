const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
const splitRoutes = require('./routes/splitRoutes');

dotenv.config();

const app = express();

// Middleware
app.use(cors({
  origin: '*', // Allow all origins (you can restrict this later)
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type'],
}));
app.use(express.json());

// Routes
app.use('/api/splits', splitRoutes);

// Optional test route for debugging connection
app.get('/api/splits/test', (req, res) => {
  res.json({ message: 'Backend is working! ✅' });
});

// MongoDB Connection & Server Start
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB Connected');
    const PORT = process.env.PORT || 5000;
    app.listen(PORT,'0.0.0.0', () => {
      console.log(`🚀 Server running at http://192.168.0.102:${PORT}`);
    });
  })
  .catch(err => console.error('❌ MongoDB Connection Error:', err));
