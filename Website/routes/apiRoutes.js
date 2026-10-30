const express     = require('express');
const router      = express.Router();
const authCtrl    = require('../controllers/api/apiAuthController');
const adminCtrl   = require('../controllers/api/apiAdminController');
const mseCtrl     = require('../controllers/api/apiMseController');

// ── Helper middleware ────────────────────────────────────────────────────────
const isAuthenticated = (req, res, next) => {
  if (!req.session.user) return res.status(401).json({ error: 'Not authenticated' });
  next();
};

const requireRole = (...roles) => (req, res, next) => {
  if (!roles.includes(req.session.user?.role))
    return res.status(403).json({ error: 'Access denied' });
  next();
};

const requireMseApproved = async (req, res, next) => {
  if (req.session.user?.role !== 'mse') return next();
  const User = require('../models/User');
  const user = await User.findById(req.session.user.id);
  if (!user?.isApproved)
    return res.status(403).json({ error: 'Your account is pending admin approval' });
  next();
};

// ── Auth routes ──────────────────────────────────────────────────────────────
router.post('/auth/login',    authCtrl.login);
router.post('/auth/register', authCtrl.register);
router.post('/auth/logout',   authCtrl.logout);
router.get('/auth/me',        authCtrl.me);

// ── Admin routes ─────────────────────────────────────────────────────────────
router.use('/admin', isAuthenticated, requireRole('admin'));
router.get('/admin/dashboard',                 adminCtrl.dashboard);
router.get('/admin/orders',                    adminCtrl.listOrders);
router.post('/admin/orders',                   adminCtrl.createOrder);
router.get('/admin/mses/pending',              adminCtrl.pendingMSEs);
router.patch('/admin/mses/:id/approve',        adminCtrl.approveMSE);
router.get('/admin/selections/pending',        adminCtrl.pendingSelections);
router.patch('/admin/selections/:id/approve',  adminCtrl.approveSelection);
router.patch('/admin/selections/:id/reject',   adminCtrl.rejectSelection);
router.get('/admin/selections/completed',      adminCtrl.completedSelections);
router.post('/admin/ratings',                  adminCtrl.submitRating);
router.get('/admin/ratings',                   adminCtrl.listRatings);

// ── MSE routes ────────────────────────────────────────────────────────────────
router.use('/mse', isAuthenticated, requireRole('mse'), requireMseApproved);
router.get('/mse/dashboard',                   mseCtrl.dashboard);
router.get('/mse/orders',                      mseCtrl.openOrders);
router.get('/mse/orders/:id',                  mseCtrl.orderDetail);
router.post('/mse/selections',                 mseCtrl.selectPortion);
router.get('/mse/selections',                  mseCtrl.mySelections);
router.patch('/mse/selections/:id/complete',   mseCtrl.completeSelection);
router.get('/mse/ratings',                     mseCtrl.myRatings);

module.exports = router;
