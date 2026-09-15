const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { dbData, saveDb, getNextId } = require('../database');
const { JWT_SECRET, verifyToken } = require('../middleware/auth');

const router = express.Router();

// Register
router.post('/register', (req, res) => {
  const { name, email, password, role = 'client', phone = '' } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Name, email, and password are required.' });
  }

  const existingUser = dbData.users.find(u => u.email.toLowerCase() === email.toLowerCase());
  if (existingUser) {
    return res.status(400).json({ error: 'An account with this email already exists.' });
  }

  const salt = bcrypt.genSaltSync(10);
  const password_hash = bcrypt.hashSync(password, salt);

  const newUser = {
    id: getNextId('users'),
    name,
    email: email.toLowerCase(),
    password_hash,
    role: ['admin', 'distributor', 'client'].includes(role) ? role : 'client',
    phone,
    created_at: new Date().toISOString()
  };

  dbData.users.push(newUser);

  // If registering as client, initialize client profile
  let clientProfile = null;
  if (newUser.role === 'client') {
    clientProfile = {
      id: getNextId('client_profiles'),
      user_id: newUser.id,
      age: 25,
      gender: 'Unspecified',
      height_cm: 170,
      weight_kg: 70,
      activity_level: 'Moderate',
      health_goals: 'General Wellness, Immunity',
      chronic_diseases: 'None',
      allergies: 'None',
      medication_notes: '',
      updated_at: new Date().toISOString()
    };
    dbData.client_profiles.push(clientProfile);
  }

  saveDb();

  const token = jwt.sign(
    { id: newUser.id, email: newUser.email, role: newUser.role, name: newUser.name },
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  res.status(201).json({
    message: 'User registered successfully',
    token,
    user: {
      id: newUser.id,
      name: newUser.name,
      email: newUser.email,
      role: newUser.role,
      phone: newUser.phone
    },
    profile: clientProfile
  });
});

// Login
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required.' });
  }

  const user = dbData.users.find(u => u.email.toLowerCase() === email.toLowerCase());
  if (!user) {
    return res.status(401).json({ error: 'Invalid email or password.' });
  }

  const isValidPassword = bcrypt.compareSync(password, user.password_hash);
  if (!isValidPassword) {
    return res.status(401).json({ error: 'Invalid email or password.' });
  }

  const token = jwt.sign(
    { id: user.id, email: user.email, role: user.role, name: user.name },
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  const profile = dbData.client_profiles.find(p => p.user_id === user.id) || null;

  res.json({
    message: 'Login successful',
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone
    },
    profile
  });
});

// Get current user profile
router.get('/me', verifyToken, (req, res) => {
  const user = dbData.users.find(u => u.id === req.user.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found.' });
  }

  const profile = dbData.client_profiles.find(p => p.user_id === user.id) || null;

  res.json({
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone,
      created_at: user.created_at
    },
    profile
  });
});

// Update Profile & Health/Chronic Diseases (Client)
router.put('/profile', verifyToken, (req, res) => {
  const {
    name,
    phone,
    age,
    gender,
    height_cm,
    weight_kg,
    activity_level,
    health_goals,
    chronic_diseases,
    allergies,
    medication_notes
  } = req.body;

  const userIndex = dbData.users.findIndex(u => u.id === req.user.id);
  if (userIndex === -1) {
    return res.status(404).json({ error: 'User not found.' });
  }

  if (name) dbData.users[userIndex].name = name;
  if (phone !== undefined) dbData.users[userIndex].phone = phone;

  let profileIndex = dbData.client_profiles.findIndex(p => p.user_id === req.user.id);
  if (profileIndex === -1) {
    const newProfile = {
      id: getNextId('client_profiles'),
      user_id: req.user.id,
      age: age || 30,
      gender: gender || 'Unspecified',
      height_cm: height_cm || 170,
      weight_kg: weight_kg || 70,
      activity_level: activity_level || 'Moderate',
      health_goals: health_goals || '',
      chronic_diseases: chronic_diseases || 'None',
      allergies: allergies || 'None',
      medication_notes: medication_notes || '',
      updated_at: new Date().toISOString()
    };
    dbData.client_profiles.push(newProfile);
    profileIndex = dbData.client_profiles.length - 1;
  } else {
    const prof = dbData.client_profiles[profileIndex];
    if (age !== undefined) prof.age = age;
    if (gender !== undefined) prof.gender = gender;
    if (height_cm !== undefined) prof.height_cm = height_cm;
    if (weight_kg !== undefined) prof.weight_kg = weight_kg;
    if (activity_level !== undefined) prof.activity_level = activity_level;
    if (health_goals !== undefined) prof.health_goals = health_goals;
    if (chronic_diseases !== undefined) prof.chronic_diseases = chronic_diseases;
    if (allergies !== undefined) prof.allergies = allergies;
    if (medication_notes !== undefined) prof.medication_notes = medication_notes;
    prof.updated_at = new Date().toISOString();
  }

  saveDb();

  res.json({
    message: 'Profile updated successfully',
    user: {
      id: dbData.users[userIndex].id,
      name: dbData.users[userIndex].name,
      email: dbData.users[userIndex].email,
      role: dbData.users[userIndex].role,
      phone: dbData.users[userIndex].phone
    },
    profile: dbData.client_profiles[profileIndex]
  });
});

module.exports = router;
