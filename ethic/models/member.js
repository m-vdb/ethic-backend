var mongoose = require('mongoose'),
    _ = require('underscore');

var contracts = require('../contracts'),
    passwordUtils = require('../auth/password');
var states = ['new', 'active', 'inactive', 'denied'];

var memberSchema = new mongoose.Schema({
  firstName: String,
  lastName: String,
  ssn: {type: String, index: {unique: true}},  // TODO: number
  email: {type: String, index: {unique: true}},
  password: {type: String},  // TODO: store hashed version + validation rules
  state: {type: String, default: 'new', enum: states},
  address: String,
  contractTypes: [{type: String, enum: contracts.contractTypes}],
  stripeId: String,
  stripeCards: [String]
}, {
  collection: 'members',
  toJSON: {
    virtuals: true,
    transform: function (doc, ret) {
      delete ret._id;
      delete ret.__v;
      delete ret.password;
    }
  }
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
  },
  hasContract: function (contractType) {
    return _.contains(this.contractTypes, contractType);
  },
  addContractType: function (contractType, cb) {
    if (this.hasContract(contractType)) return cb();
    this.contractTypes.push(contractType);
    this.save(cb);
  }
});


memberSchema.pre('save', function (cb) {
  if (!this.isNew) return cb();
  if (!this.password) return cb(new Error('Missing password.'));

  this.password = passwordUtils.hashPassword(this.password);
  cb();
});

module.exports = mongoose.model('Member', memberSchema);
