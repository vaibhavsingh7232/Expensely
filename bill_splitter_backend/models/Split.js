const mongoose = require('mongoose');

const SplitSchema = new mongoose.Schema({
  groupName: {
    type: String,
    required: true,
  },
  people: [String],
  amounts: [Number],
  selectedIndices: [Number],
  transactions: [
    {
      from: String,
      to: String,
      amount: Number
    }
  ],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Split', SplitSchema);
