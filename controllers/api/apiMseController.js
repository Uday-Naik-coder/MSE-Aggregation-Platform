const Order     = require('../../models/Order');
const Selection = require('../../models/Selection');
const Rating    = require('../../models/Rating');

// GET /api/mse/dashboard
const dashboard = async (req, res) => {
  try {
    const mseId = req.session.user.id;
    const selections = await Selection.find({ mseId });
    const ratings    = await Rating.find({ mseId });

    const availableOrders      = await Order.countDocuments({ status: 'open', deadline: { $gt: new Date() } });
    const pendingSelections    = selections.filter(s => s.status === 'pending').length;
    const approvedSelections   = selections.filter(s => s.status === 'approved').length;
    const completedSelections  = selections.filter(s => s.status === 'completed').length;
    const avgRating = ratings.length
      ? ratings.reduce((s, r) => s + r.overallRating, 0) / ratings.length : 0;

    res.json({ availableOrders, pendingSelections, approvedSelections, completedSelections, avgRating });
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// GET /api/mse/orders
const openOrders = async (req, res) => {
  try {
    const orders = await Order.find({ status: 'open', deadline: { $gt: new Date() } }).sort('-createdAt');
    res.json(orders);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// GET /api/mse/orders/:id
const orderDetail = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json({ order });
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// POST /api/mse/selections
const selectPortion = async (req, res) => {
  const { orderId, selectedQuantity } = req.body;
  try {
    const order = await Order.findById(orderId);
    if (!order || order.status !== 'open' || new Date() > order.deadline)
      return res.status(400).json({ error: 'Order not available' });

    const existing = await Selection.findOne({ orderId, mseId: req.session.user.id });
    if (existing)
      return res.status(409).json({ error: 'You already submitted a selection for this order', code: 'DUPLICATE_SELECTION' });

    const selection = new Selection({
      orderId, mseId: req.session.user.id, selectedQuantity, status: 'pending'
    });
    await selection.save();
    res.status(201).json({ message: 'Selection submitted', selection });
  } catch (err) { res.status(500).json({ error: 'Failed to submit selection' }); }
};

// GET /api/mse/selections
const mySelections = async (req, res) => {
  try {
    const selections = await Selection.find({ mseId: req.session.user.id })
      .populate('orderId').sort('-createdAt');
    res.json(selections);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// PATCH /api/mse/selections/:id/complete
const completeSelection = async (req, res) => {
  try {
    const selection = await Selection.findOne({ _id: req.params.id, mseId: req.session.user.id });
    if (!selection) return res.status(404).json({ error: 'Selection not found' });
    if (selection.status !== 'approved')
      return res.status(400).json({ error: 'Only approved selections can be marked complete' });

    selection.status = 'completed';
    selection.completedAt = new Date();
    await selection.save();
    res.json({ message: 'Marked as completed', selection });
  } catch (err) { res.status(500).json({ error: 'Failed to complete selection' }); }
};

// GET /api/mse/ratings
const myRatings = async (req, res) => {
  try {
    const ratings = await Rating.find({ mseId: req.session.user.id })
      .populate('orderId').sort('-createdAt');
    res.json(ratings);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

module.exports = { dashboard, openOrders, orderDetail, selectPortion, mySelections, completeSelection, myRatings };
