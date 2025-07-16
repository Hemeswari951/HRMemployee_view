const express = require('express');
const router = express.Router();
const ToDo = require('../models/Todo');

// ✅ Calculate Overall Work Progress - REGISTER THIS FIRST
router.get('/todo/progress', async (req, res) => {
  try {
    const todos = await ToDo.find();

    if (!todos || todos.length === 0) {
      return res.json({ progress: 0 });
    }

    let totalProgress = 0;
    let totalTasks = 0;

    todos.forEach((entry) => {
      entry.tasks.forEach((task) => {
        const status = (task.status || '').toLowerCase().trim();
        const eta = parseInt(task.eta);

        if (status === 'completed') {
          totalProgress += 100;
        } else if (status === 'yet to start') {
          totalProgress += 0;
        } else if (status === 'in progress') {
          totalProgress += !isNaN(eta) ? eta : 50;
        }

        totalTasks++;
      });
    });

    const finalProgress = totalTasks > 0 ? Math.round(totalProgress / totalTasks) : 0;
    res.json({ progress: finalProgress });
  } catch (err) {
    console.error('❌ Progress Calculation Error:', err);
    res.status(500).json({ error: 'Failed to calculate progress' });
  }
});

// ✅ Save or Update Task
router.post('/todo/save', async (req, res) => {
  const { date, workStatus, tasks } = req.body;

  try {
    let todo = await ToDo.findOne({ date });

    if (todo) {
      todo.workStatus = workStatus;
      todo.tasks = tasks;
      await todo.save();
      res.json({ message: 'Task Updated' });
    } else {
      const newTodo = new ToDo({ date, workStatus, tasks });
      await newTodo.save();
      res.json({ message: 'Task Saved' });
    }
  } catch (err) {
    console.error('❌ Save Error:', err);
    res.status(500).json({ error: 'Save Failed' });
  }
});

// ✅ Get tasks by date (REGISTER THIS LAST to avoid conflict with '/progress')
router.get('/todo/:date', async (req, res) => {
  try {
    const date = req.params.date;
    const todo = await ToDo.findOne({ date });

    if (todo) {
      res.json(todo);
    } else {
      res.status(404).json({ message: 'No tasks found for this date' });
    }
  } catch (err) {
    console.error('❌ Fetch error:', err);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

module.exports = router;
