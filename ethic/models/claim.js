var mongoose = require('mongoose');

var claimSchema = new mongoose.Schema({
  member: {type: mongoose.Schema.Types.ObjectId, ref: 'Member'},
  policy: {type: mongoose.Schema.Types.ObjectId, ref: 'Policy'},
  description: String,
  date: Date,
  location: String,
  driversCount: Number,
  atFault: {type: Boolean, default: true},
  wentToGarage: Boolean,
  estimate: {type: Number, default: 0},
  estimateFile: mongoose.Schema.Types.ObjectId,
  pictures: [mongoose.Schema.Types.ObjectId]
}, {
  collection: 'claims',
  toJSON: {
    virtuals: true,
    transform: function (doc, ret) {
      delete ret._id;
      delete ret.__v;
    }
  }
});

module.exports =  mongoose.model('Claim', claimSchema);
