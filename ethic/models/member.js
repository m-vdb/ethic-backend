var mongoose = require('mongoose'),
    _ = require('underscore');

var contracts = _.keys(require('../contracts'));
var states = ['new', 'active', 'inactive', 'denied'];

var memberSchema = new mongoose.Schema({
  firstName: String,
  lastName: String,
  ssn: {type: String, index: {unique: true}},  // TODO: number
  email: {type: String, index: {unique: true}},
  state: {type: String, default: 'new', enum: states},
  address: String,
  contractTypes: [{type: String, enum: contracts}]
}, {
  collection: 'members'
});

memberSchema.method({
  isNotNew: function () {
    return this.state !== 'new';
  },
  isActive: function () {
    return this.state == 'active';
  },
  activate: function (cb) {
    this.state = 'active';
    this.save(cb);
  },
  deny: function (cb) {
    this.state = 'denied';
    this.save(cb);
  },
  getPolicies: function (cb) {
    mongoose.model('Policy').find({member: this._id}, cb);
  }
});

module.exports = mongoose.model('Member', memberSchema);
