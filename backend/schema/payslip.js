const mongoose = require('mongoose');

const earningsSchema = new mongoose.Schema({
  basic_salary: { type: String, default: '0' },
  house_rent_allowance: { type: String, default: '0' },
  conveyance_allowance: { type: String, default: '0' },
  medical_allowance: { type: String, default: '0' },
  special_allowance: { type: String, default: '0' },
  gross_salary: { type: String, default: '0' }
}, { _id: false });

const deductionsSchema = new mongoose.Schema({
  epf: { type: String, default: '0' },
  health_insurance: { type: String, default: '0' },
  professional_tax: { type: String, default: '0' },
  total_deductions: { type: String, default: '0' },
  net_pay: { type: String, default: '0' }
}, { _id: false });

const monthDataSchema = new mongoose.Schema({
  earnings: { type: earningsSchema, default: () => ({}) },
  deductions: { type: deductionsSchema, default: () => ({}) }
}, { _id: false });

const yearSchema = new mongoose.Schema({
  year: String,
  months: {
    jan: { type: monthDataSchema, default: () => ({}) },
    feb: { type: monthDataSchema, default: () => ({}) },
    mar: { type: monthDataSchema, default: () => ({}) },
    apr: { type: monthDataSchema, default: () => ({}) },
    may: { type: monthDataSchema, default: () => ({}) },
    jun: { type: monthDataSchema, default: () => ({}) },
    jul: { type: monthDataSchema, default: () => ({}) },
    aug: { type: monthDataSchema, default: () => ({}) },
    sep: { type: monthDataSchema, default: () => ({}) },
    oct: { type: monthDataSchema, default: () => ({}) },
    nov: { type: monthDataSchema, default: () => ({}) },
    dec: { type: monthDataSchema, default: () => ({}) }
  }
}, { _id: false });

const payslipSchema = new mongoose.Schema({
  name: String,
  employee_id: String,
  designation: String,
  bank_name: String,
  department: String,
  account_no: String,
  location: String,
  lop: { type: String, default: '0.0' },
  data_years: [yearSchema]
}, { timestamps: true });

module.exports = mongoose.model('Payslip', payslipSchema);
