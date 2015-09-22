var mongoose = require('mongoose');

var states = ['new', 'active', 'inactive', 'denied'];
var memberSchema = new mongoose.Schema({
  firstName: String,
  lastName: String,
  ssn: {type: String, index: {unique: true}},  // TODO: number
  email: {type: String, index: {unique: true}},
  state: {type: String, default: 'new', enum: states},
  address: String
}, {
  collection: 'members'
});

memberSchema.method({
  isNotNew: function () {
    return this.state !== 'new';
  },
  isActive: function () {
    return this.state !== 'active';
  },
  activate: function (cb) {
    this.state = 'active';
    this.save(cb);
  },
  deny: function (cb) {
    this.state = 'denied';
    this.save(cb);
  }
});

module.exports = mongoose.model('Member', memberSchema);
