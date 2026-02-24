const express = require('express');
const router = express.Router();
const passport = require('../config/passport');
const User = require('../models/User');

// Middleware to prevent authenticated users from accessing guest pages
function ensureGuest(req, res, next) {
  if (req.isAuthenticated()) return res.redirect('/dashboard');
  next();
}

// Middleware to protect routes that require authentication
function ensureAuth(req, res, next) {
  if (req.isAuthenticated()) return next();
  res.redirect('/login');
}

// Redirect root to login
router.get('/', (req, res) => res.redirect('/login'));

// Login page (guest only)
router.get('/login', ensureGuest, (req, res) => {
  res.render('login', { error: req.flash('error') });
});

// Signup page (guest only)
router.get('/signup', ensureGuest, (req, res) => {
  res.render('signup', { error: req.flash('error') });
});

// Dashboard (protected)
router.get('/dashboard', ensureAuth, (req, res) => {
  res.render('dashboard', { user: req.user });
});

// ----- AI Module Routes (all protected) -----
router.get('/inventory-twin', ensureAuth, (req, res) => {
  res.render('inventory-twin', { user: req.user });
});

router.get('/demand-forecast', ensureAuth, (req, res) => {
  res.render('demand-forecast', { user: req.user });
});

router.get('/matchmaking', ensureAuth, (req, res) => {
  res.render('matchmaking', { user: req.user });
});

router.get('/logistics', ensureAuth, (req, res) => {
  res.render('logistics', { user: req.user });
});

router.get('/crm', ensureAuth, (req, res) => {
  res.render('crm', { user: req.user });
});

router.get('/payments', ensureAuth, (req, res) => {
  res.render('payments', { user: req.user });
});

// ----- Authentication POST routes -----
router.post('/login', ensureGuest, passport.authenticate('local', {
  successRedirect: '/dashboard',
  failureRedirect: '/login',
  failureFlash: true
}));

// Signup POST – now includes role field
router.post('/signup', ensureGuest, async (req, res) => {
  try {
    const { name, email, password, confirmPassword, role } = req.body;

    if (!name || !email || !password || !role) {
      req.flash('error', 'Please fill in all fields, including role.');
      return res.redirect('/signup');
    }

    if (password.length < 6) {
      req.flash('error', 'Password must be at least 6 characters.');
      return res.redirect('/signup');
    }

    if (password !== confirmPassword) {
      req.flash('error', 'Passwords do not match.');
      return res.redirect('/signup');
    }

    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      req.flash('error', 'Email already registered.');
      return res.redirect('/signup');
    }

    await User.create({ name, email, password, role });

    req.flash('error', 'Account created! Please log in.');
    res.redirect('/login');

  } catch (err) {
    console.error(err);
    req.flash('error', 'Something went wrong.');
    res.redirect('/signup');
  }
});

// Google OAuth routes
router.get('/auth/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

router.get('/auth/google/callback',
  passport.authenticate('google', {
    successRedirect: '/dashboard',
    failureRedirect: '/login',
    failureFlash: true
  })
);

// Logout
router.get('/logout', (req, res, next) => {
  req.logout(err => {
    if (err) return next(err);
    res.redirect('/login');
  });
});

module.exports = router;