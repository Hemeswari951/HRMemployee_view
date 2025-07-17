const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// -----------------------------
// 🔌 Middleware
// -----------------------------
app.use(cors({
  origin: ['https://zeaihrm.netlify.app', 'http://localhost:3000'], // ✅ ADD localhost for testing too
  credentials: true
}));

app.use(express.json());

app.use((req, res, next) => {
  console.log(`📥 ${req.method} ${req.originalUrl}`);
  next();
});

// -----------------------------
// 🛠️ MongoDB Connection
// -----------------------------
mongoose
  .connect(process.env.MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
  })
  .then(() => console.log('✅ MongoDB connected'))
  .catch((err) => console.error('❌ MongoDB connection error:', err));

// -----------------------------
// 📦 Routes
// -----------------------------
const Payslip = require('./schema/payslip');
const leaveRoutes = require('./routes/leave');
const profile = require('./routes/profile-route');
const todoRoutes = require('./routes/todo');
const attendanceRoutes = require('./routes/attendance');
const performanceRoutes = require('./routes/performance');

app.use('/apply', leaveRoutes);
app.use('/profile', profile);
app.use('/todo_planner', todoRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/perform', performanceRoutes);

// -----------------------------
// 📄 Payslip Routes
// -----------------------------
app.get('/get-payslip-details', async (req, res) => {
  try {
    const { employee_id, year, month } = req.query;
    const payslip = await Payslip.findOne({ employee_id });
    if (!payslip) return res.status(404).json({ message: 'Payslip not found' });

    const yearData = payslip.data_years.find(y => y.year === year);
    if (!yearData) return res.status(404).json({ message: 'Year not found' });

    const monthKey = month.toLowerCase().slice(0, 3);
    const monthData = yearData.months[monthKey];
    if (!monthData) return res.status(404).json({ message: 'Month data not found' });

    res.json({
      name: payslip.name,
      employee_id: payslip.employee_id,
      designation: payslip.designation,
      bank_name: payslip.bank_name,
      department: payslip.department,
      account_no: payslip.account_no,
      location: payslip.location,
      lop: payslip.lop,
      earnings: monthData.earnings,
      deductions: monthData.deductions
    });
  } catch (error) {
    console.error('❌ Fetch Payslip Error:', error);
    res.status(500).json({ message: 'Failed to fetch payslip data', error: error.message });
  }
});

app.post('/get-multiple-payslips', async (req, res) => {
  try {
    const { employee_id, year, months } = req.body;
    if (!employee_id || !year || !Array.isArray(months)) {
      return res.status(400).json({ message: 'Missing or invalid fields' });
    }

    const payslip = await Payslip.findOne({ employee_id });
    if (!payslip) return res.status(404).json({ message: 'Employee not found' });

    const yearData = payslip.data_years.find(y => y.year === year);
    if (!yearData) return res.status(404).json({ message: 'Year not found' });

    const results = {};
    months.forEach(month => {
      const monthKey = month.toLowerCase().slice(0, 3);
      const monthData = yearData.months[monthKey];
      if (monthData) results[monthKey] = monthData;
    });

    res.status(200).json({
      employeeInfo: {
        name: payslip.name,
        employee_id: payslip.employee_id,
        designation: payslip.designation,
        bank_name: payslip.bank_name,
        department: payslip.department,
        account_no: payslip.account_no,
        location: payslip.location,
        lop: payslip.lop,
      },
      months: results
    });
  } catch (error) {
    console.error('❌ Get Multiple Payslips Error:', error);
    res.status(500).json({ message: 'Failed to fetch payslip data', error: error.message });
  }
});

// -----------------------------
// 👤 Employee Auth
// -----------------------------
const employeeSchema = new mongoose.Schema({
  employeeId: String,
  employeeName: String,
  position: String
});
const Employee = mongoose.model('Employee', employeeSchema);

app.post('/employee-login', async (req, res) => {
  const { employeeId, employeeName, position } = req.body;

  if (!employeeId || !employeeName || !position) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const user = await Employee.findOne({
      employeeId: employeeId.trim(),
      employeeName: employeeName.trim(),
      position: position.trim()
    });

    if (user) {
      res.status(201).json({ message: '✅ Login Successful' });
    } else {
      res.status(401).json({ message: '❌ Invalid Credentials' });
    }
  } catch (error) {
    console.error('❌ Login Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

app.get('/get-employee-name/:employeeId', async (req, res) => {
  try {
    const employee = await Employee.findOne({ employeeId: req.params.employeeId.trim() });

    if (employee) {
      res.status(200).json({
        employeeName: employee.employeeName,
        position: employee.position
      });
    } else {
      res.status(404).json({ message: 'Employee not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

// 🏠 Root Route
app.get('/', (req, res) => {
  res.send('✅ HRM Backend is up and running!');
});

// 🚀 Start Server
app.listen(PORT, () =>
  console.log(`🚀 Server running on port ${PORT}`)
);
