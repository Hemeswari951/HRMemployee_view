const express = require('express');
const router = express.Router();
const Employee = require('../models/employee');

// @route   POST /api/employee
// @desc    Create a new employee profile
router.post('/', async (req, res) => {
  try {
    const employee = new Employee(req.body);
    await employee.save();
    res.status(201).json({ message: '✅ Employee created successfully', employee });
  } catch (error) {
    console.error('❌ Failed to create employee:', error.message);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});
router.post('/', async (req, res) => {
  console.log('📩 POST /api/employee hit');

});


// @route   GET /api/employee/:id
// @desc    Get an employee by ID
router.get('/:id', async (req, res) => {
  try {
    const employee = await Employee.findOne({ id: req.params.id });
    if (!employee) {
      return res.status(404).json({ message: '❌ Employee not found' });
    }
    res.status(200).json(employee);
  } catch (error) {
    console.error('❌ Failed to fetch employee:', error.message);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

module.exports = router;