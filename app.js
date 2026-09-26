require('dotenv').config();
const express      = require('express');
const mongoose     = require('mongoose');
const session      = require('express-session');
const MongoStore   = require('connect-mongo').default;
const flash        = require('express-flash');
const methodOverride = require('method-override');
const path         = require('path');
const cors         = require('cors');

// Import all routes
const indexRoutes  = require('./routes/indexRoutes');
const authRoutes   = require('./routes/authRoutes');
const adminRoutes  = require('./routes/adminRoutes');
const mseRoutes    = require('./routes/mseRoutes');
const apiRoutes    = require('./routes/apiRoutes');   // ← NEW mobile API

const app  = express();
const PORT = process.env.PORT || 3000;

// ── CORS (required for Flutter mobile client) ─────────────────────────────
app.use(cors({
  origin: [
    'http://10.0.2.2:3000',      // Android emulator → host machine
    'http://localhost:3000',
    process.env.MOBILE_ORIGIN    // set in .env for physical device LAN IP
  ].filter(Boolean),
  credentials: true
}));

// ── View engine ───────────────────────────────────────────────────────────
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// ── Middleware ────────────────────────────────────────────────────────────
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(methodOverride('_method'));
app.use(express.static(path.join(__dirname, 'public')));

// ── Session ───────────────────────────────────────────────────────────────
app.use(session({
  secret: process.env.SESSION_SECRET || 'fallback-secret',
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({
    mongoUrl: process.env.MONGODB_URI || 'mongodb://localhost:27017/mse_platform',
    collectionName: 'sessions'
  }),
  cookie: {
    maxAge: 1000 * 60 * 60 * 24,  // 1 day
    sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'lax',
    secure: process.env.NODE_ENV === 'production'
  }
}));

// ── Flash messages ────────────────────────────────────────────────────────
app.use(flash());
app.use((req, res, next) => {
  res.locals.user        = req.session.user || null;
  res.locals.success_msg = req.flash('success');
  res.locals.error_msg   = req.flash('error');
  next();
});

// ── REST API (mobile) — mount BEFORE EJS routes ──────────────────────────
app.use('/api', apiRoutes);

// ── EJS Web routes (unchanged) ────────────────────────────────────────────
app.use('/',      indexRoutes);
app.use('/auth',  authRoutes);
app.use('/admin', adminRoutes);
app.use('/mse',   mseRoutes);

// ── Health check ──────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

// ── 404 ───────────────────────────────────────────────────────────────────
app.use((req, res) => {
  if (req.path.startsWith('/api')) return res.status(404).json({ error: 'Not found' });
  res.status(404).render('404', { url: req.originalUrl });
});

// ── Connect and start ─────────────────────────────────────────────────────
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/mse_platform')
  .then(() => {
    console.log('MongoDB connected');
    app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
  })
  .catch(err => {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  });

module.exports = app;
