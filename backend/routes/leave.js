

const express = require('express');
const router = express.Router();
const Leave = require('../models/leave');

// ✅ Existing apply-leave route (untouched)
router.post('/apply-leave', async (req, res) => {
  try {
    const { employeeId, employeeName, leaveType, approver, fromDate, toDate, reason } = req.body;

    if (!employeeId || !employeeName || !leaveType || !approver || !fromDate || !toDate || !reason) {
      return res.status(400).json({ message: 'All fields are required.' });
    }

    const newLeave = new Leave({
      employeeId,
      employeeName,
      leaveType,
      approver,
      fromDate,
      toDate,
      reason,
      status: 'Pending'
    });

    await newLeave.save();

    res.status(201).json({ message: '✅ Leave applied successfully' });
  } catch (error) {
    console.error('❌ Error applying leave:', error);
    res.status(500).json({ message: '❌ Server error', error: error.message });
  }
});

// ✅ NEW leave-stats route (for Analytics Dashboard)
router.get('/leave-stats', async (req, res) => {
  try {
    const totalLeavesAllowed = 36; // Set your max allowed leaves
    const totalLeavesUsed = await Leave.countDocuments();

    const leavePercentage = totalLeavesAllowed === 0
      ? 0
      : ((totalLeavesUsed / totalLeavesAllowed) * 100).toFixed(0); // ✅ Correct in JS

    const presentPercentage = (100 - leavePercentage).toFixed(0);

    res.json({
      totalLeavesUsed,
      leavePercentage,
      presentPercentage
    });
  } catch (err) {
    console.error('❌ Error calculating leave stats:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});




router.get('/fetch/:employeeId', async (req, res) => {
  try {
    const { status } = req.query;
    const employeeId = req.params.employeeId.trim();

    const filter = { employeeId };

    if (status) {
      filter.status = status;
    }

    const leaves = await Leave.find(filter);
    res.json(leaves);
  } catch (err) {
    console.error('❌ Error fetching leaves:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});


// ✅ Cancel Leave (soft delete by setting status)
// Route: /apply/cancel/:id
// ✅ Correct format
// DELETE leave by both employeeId and leaveId
router.delete('/delete/:employeeId/:id', async (req, res) => {
  const { employeeId, id } = req.params;
  console.log(`🛠 Received DELETE for employeeId: ${employeeId}, id: ${id}`);

  try {
    const leave = await Leave.findOne({ _id: id, employeeId: employeeId });
    if (!leave) {
      console.warn('⚠️ Leave not found for this employee');
      return res.status(404).json({ message: 'Leave not found for this employee' });
    }

    leave.status = 'Cancelled';
    await leave.save();

    console.log('✅ Leave status updated to Cancelled');
    res.json({ message: 'Leave cancelled successfully' });
  } catch (err) {
    console.error('❌ Error cancelling leave:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});



// PUT /apply/update/:employeeId/:id
router.put('/update/:employeeId/:id', async (req, res) => {
  const { employeeId, id } = req.params;
  const updatedData = req.body;

  try {
    const leave = await Leave.findOne({ _id: id, employeeId: employeeId });
    if (!leave) {
      return res.status(404).json({ message: 'Leave not found' });
    }

    leave.leaveType = updatedData.leaveType;
    leave.fromDate = updatedData.fromDate;
    leave.toDate = updatedData.toDate;
    leave.reason = updatedData.reason;
    leave.status = 'Pending'; // Reset status if needed

    await leave.save();
    res.status(200).json({ message: 'Leave updated successfully' });
  } catch (err) {
    console.error('❌ Error updating leave:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});





module.exports = router;