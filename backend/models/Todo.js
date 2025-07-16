const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  item: String,
  eta: String,
  status: String,
});

const ToDoSchema = new mongoose.Schema({
  date: { type: String, required: true },
  workStatus: { type: String, required: true },
  tasks: [TaskSchema],
});

module.exports = mongoose.model('ToDo', ToDoSchema);