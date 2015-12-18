'use strict';
var mongoose = require('mongoose');

var claimSchema = new mongoose.Schema({
  member: {type: mongoose.Schema.Types.ObjectId, ref: 'Member', required: true},
  policy: {type: mongoose.Schema.Types.ObjectId, ref: 'Policy', required: true},
  description: {type: String, required: true, minlength: 50},
  date: {type: Date, required: true},
  location: {type: String, required: true},
  driversCount: {type: Number, default: 1},
  atFault: {type: Boolean, default: true},
  wentToGarage: {type: Boolean, default: false},
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
