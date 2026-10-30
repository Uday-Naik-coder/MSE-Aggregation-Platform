const Order     = require('../../models/Order');
const Selection = require('../../models/Selection');
const User      = require('../../models/User');
const Rating    = require('../../models/Rating');

// GET /api/admin/dashboard
const dashboard = async (req, res) => {
  try {
    const [totalOrders, openOrders, pendingSelections, pendingMSEs, completedSelections] =
      await Promise.all([
        Order.countDocuments(),
        Order.countDocuments({ status: 'open', deadline: { $gt: new Date() } }),
        Selection.countDocuments({ status: 'pending' }),
        User.countDocuments({ role: 'mse', isApproved: false }),
        Selection.countDocuments({ status: 'completed' }),
      ]);
    res.json({ totalOrders, openOrders, pendingSelections, pendingMSEs, completedSelections });
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// GET /api/admin/orders
const listOrders = async (req, res) => {
  try {
    const orders = await Order.find().populate('createdBy', 'name email').sort('-createdAt');
    res.json(orders);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// POST /api/admin/orders
const createOrder = async (req, res) => {
  const { description, totalQuantity, deadline, pricePerUnit } = req.body;
  try {
    const order = new Order({
      description, totalQuantity, deadline, pricePerUnit,
      createdBy: req.session.user.id, status: 'open'
    });
    await order.save();
    res.status(201).json({ message: 'Order created', order });
  } catch (err) { res.status(500).json({ error: 'Failed to create order' }); }
};

// GET /api/admin/mses/pending
const pendingMSEs = async (req, res) => {
  try {
    const mses = await User.find({ role: 'mse', isApproved: false }).select('-password');
    res.json(mses);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// PATCH /api/admin/mses/:id/approve
const approveMSE = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.params.id, { isApproved: true });
    res.json({ message: 'MSE approved successfully' });
  } catch (err) { res.status(500).json({ error: 'Failed to approve MSE' }); }
};

// GET /api/admin/selections/pending
const pendingSelections = async (req, res) => {
  try {
    const selections = await Selection.find({ status: 'pending' })
      .populate('orderId').populate('mseId', '-password');
    res.json(selections);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// PATCH /api/admin/selections/:id/approve
const approveSelection = async (req, res) => {
  try {
    const selection = await Selection.findById(req.params.id).populate('orderId');
    if (!selection) return res.status(404).json({ error: 'Selection not found' });

    const approved = await Selection.find({ orderId: selection.orderId._id, status: 'approved' });
    const totalApproved = approved.reduce((sum, s) => sum + s.selectedQuantity, 0);

    if (totalApproved + selection.selectedQuantity > selection.orderId.totalQuantity) {
      return res.status(422).json({
        error: 'Approval would exceed the order quantity.',
        code: 'QUANTITY_EXCEEDED'
      });
    }

    selection.status = 'approved';
    selection.adminApprovedAt = new Date();
    await selection.save();
    res.json({ message: 'Selection approved' });
  } catch (err) { res.status(500).json({ error: 'Failed to approve selection' }); }
};

// PATCH /api/admin/selections/:id/reject
const rejectSelection = async (req, res) => {
  try {
    await Selection.findByIdAndUpdate(req.params.id, { status: 'rejected' });
    res.json({ message: 'Selection rejected' });
  } catch (err) { res.status(500).json({ error: 'Failed to reject selection' }); }
};

// GET /api/admin/selections/completed
const completedSelections = async (req, res) => {
  try {
    const selections = await Selection.find({ status: 'completed' })
      .populate('orderId').populate('mseId', '-password').sort('-completedAt');
    res.json(selections);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

// POST /api/admin/ratings
const submitRating = async (req, res) => {
  const { selectionId, timelinessScore, qualityScore, communicationScore, comment } = req.body;
  try {
    const selection = await Selection.findById(selectionId);
    if (!selection || selection.status !== 'completed')
      return res.status(400).json({ error: 'Only completed selections can be rated' });

    const existing = await Rating.findOne({ orderId: selection.orderId, mseId: selection.mseId });
    if (existing) return res.status(409).json({ error: 'Rating already submitted for this order/MSE combination' });

    const rating = new Rating({
      orderId: selection.orderId, mseId: selection.mseId,
      adminId: req.session.user.id,
      timelinessScore, qualityScore,
      ...(communicationScore ? { communicationScore } : {}),
      ...(comment ? { comment } : {})
    });
    await rating.save();
    res.status(201).json({ message: 'Rating submitted', rating });
  } catch (err) { res.status(500).json({ error: 'Failed to submit rating' }); }
};

// GET /api/admin/ratings
const listRatings = async (req, res) => {
  try {
    const ratings = await Rating.find().populate('orderId').populate('mseId', '-password').sort('-createdAt');
    res.json(ratings);
  } catch (err) { res.status(500).json({ error: 'Server error' }); }
};

module.exports = {
  dashboard, listOrders, createOrder,
  pendingMSEs, approveMSE,
  pendingSelections, approveSelection, rejectSelection, completedSelections,
  submitRating, listRatings
};
