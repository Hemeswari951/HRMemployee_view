const mongoose = require('mongoose');

const employeeSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  full_name: { type: String, required: true },
  dob: { type: String },
  father_name: { type: String },
  father_occupation: { type: String },
  aadhar: { type: String },
  address: { type: String }
});

module.exports = mongoose.model('profile', employeeSchema);