const User    = require('../../models/User');
const bcrypt  = require('bcryptjs');

// POST /api/auth/login
const login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ error: 'Invalid credentials' });

    // Store in session
    req.session.user = {
      id: user._id, email: user.email, role: user.role, name: user.name
    };

    return res.json({
      message: 'Login successful',
      user: {
        _id: user._id, email: user.email, role: user.role,
        name: user.name, businessName: user.businessName,
        registrationId: user.registrationId, isApproved: user.isApproved,
        createdAt: user.createdAt
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
};

// POST /api/auth/register
const register = async (req, res) => {
  const { name, businessName, registrationId, email, password } = req.body;
  try {
    const existing = await User.findOne({ $or: [{ email }, { registrationId }] });
    if (existing) return res.status(409).json({ error: 'Email or Registration ID already in use' });

    const hashed = await bcrypt.hash(password, 10);
    const user = new User({
      email, password: hashed, role: 'mse',
      name, businessName, registrationId, isApproved: false
    });
    await user.save();
    res.status(201).json({ message: 'Registration successful. Waiting for admin approval.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Registration failed' });
  }
};

// POST /api/auth/logout
const logout = (req, res) => {
  req.session.destroy();
  res.json({ message: 'Logged out successfully' });
};

// GET /api/auth/me
const me = async (req, res) => {
  if (!req.session.user) return res.status(401).json({ error: 'Not authenticated' });
  try {
    const user = await User.findById(req.session.user.id).select('-password');
    if (!user) return res.status(401).json({ error: 'User not found' });
    res.json({ user });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
};

module.exports = { login, register, logout, me };
