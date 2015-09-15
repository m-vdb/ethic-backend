var mongoose = require('mongoose');

var states = ['new', 'active', 'inactive', 'denied'];
var memberSchema = new mongoose.Schema({
  firstName: String,
  lastName: String,
  ssn: {type: String, index: {unique: true}},
  email: {type: String, index: {unique: true}},
  state: {type: String, default: 'new', enum: states},
  address: String
}, {
  collection: 'members'
});

memberSchema.methods.isNew = function () {
  return this.state == 'new';
};

module.exports = mongoose.model('Member', memberSchema);
