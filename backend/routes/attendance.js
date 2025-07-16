//routes/attendance.js : 


const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();

// ✅ Updated Attendance Schema
const attendanceSchema = new mongoose.Schema({
  employeeId: String, // 👈 added
  date: String,
  loginTime: String,
  logoutTime: String,
  breakTime: String,
  loginReason: String,
  logoutReason: String,
}, { timestamps: true });

const Attendance = mongoose.model('Attendance', attendanceSchema);

// ✅ POST: Save attendance for employee
router.post('/attendance/mark/:employeeId', async (req, res) => {
  const { employeeId } = req.params;
  const { date, loginTime, logoutTime, breakTime, loginReason, logoutReason } = req.body;

  try {
    const newAttendance = new Attendance({
      employeeId,
      date,
      loginTime,
      logoutTime,
      breakTime,
      loginReason,
      logoutReason,
    });

    await newAttendance.save();
    res.status(201).json({ message: 'Attendance saved successfully' });
  } catch (error) {
    console.error('❌ Error saving attendance:', error);
    res.status(500).json({ message: 'Server Error' });
  }
});

// ✅ PUT: Update attendance by employeeId and date
router.put('/attendance/update/:employeeId', async (req, res) => {
  const { employeeId } = req.params;
  const { date, loginTime, logoutTime, breakTime, loginReason, logoutReason } = req.body;

  if (!date) {
    return res.status(400).json({ message: 'Date is required to update attendance' });
  }

  try {
    const updatedAttendance = await Attendance.findOneAndUpdate(
      { employeeId, date },
      {
        $set: {
          loginTime,
          logoutTime,
          breakTime,
          loginReason,
          logoutReason,
        },
      },
      { new: true }
    );

    if (!updatedAttendance) {
      return res.status(404).json({ message: 'Attendance record not found for this employee/date' });
    }

    res.status(200).json({ message: 'Attendance updated successfully', updatedAttendance });
  } catch (error) {
    console.error('❌ Error updating attendance:', error);
    res.status(500).json({ message: 'Server Error' });
  }
});

// ✅ GET: Last 5 attendance records for an employee
router.get('/attendance/history/:employeeId', async (req, res) => {
  const { employeeId } = req.params;

  try {
    const records = await Attendance.find({ employeeId })
      .sort({ createdAt: -1 })
      .limit(5);

    res.status(200).json(records);
  } catch (error) {
    console.error('❌ Error fetching history:', error);
    res.status(500).json({ message: 'Error fetching attendance history' });
  }
});



// ✅ GET: Check if login already done for the day
router.get('/attendance/check/:employeeId/:date', async (req, res) => {
  const { employeeId, date } = req.params;

  try {
    const existingRecord = await Attendance.findOne({ employeeId, date });
    if (existingRecord) {
      return res.status(200).json({ exists: true });
    } else {
      return res.status(200).json({ exists: false });
    }
  } catch (error) {
    console.error('❌ Error checking attendance:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


module.exports = router;