var mongoose = require('mongoose');
require('mongoose-schema-extend');

var contracts = require('../contracts'),
    cars = require('../utils/cars.js');

var policySchema = new mongoose.Schema({
  member: {type: mongoose.Schema.Types.ObjectId, ref: 'Member'},
  initial_premium: Number,
  initial_deductible: Number,
  contractType: {type: String, enum: contracts.contractTypes}
}, {
  collection: 'policies',
  discriminatorKey: '_type',
  toJSON: {
    virtuals: true,
    transform: function (doc, ret) {
      delete ret._id;
      delete ret.__v;
    }
  }
});

policySchema.static({
  modelFromType: function (type) {
    try {
      return mongoose.model(type);
    }
    catch (e) {
      if (e instanceof mongoose.Error.MissingSchemaError) throw new Error('Unknown policy type: ' + type);
      throw e;  // throw back other errors
    }
  },
  getPolicyTypes: function () {
    return ['CarPolicy'];
  }
});

var carPolicySchema = policySchema.extend({
  car_vin: {type: String, maxLength: 17, minLength: 17, uppercase: true},
  car_year: {type: Number, min: 2000, max: new Date().getFullYear()},
  car_make_id: {type: String},
  car_make: {type: String},
  car_model_id: {type: String},
  car_model: {type: String}
});


carPolicySchema.pre('save', function (cb) {
  if (!this.isNew) return cb();

  // if new, decode the vin
  if (!this.car_vin) cb(new Error('Missing car VIN.'));
  var policy = this;
  cars.decodeVin(this.car_vin, function (err, resp) {
    if (err) return cb(err);

    policy.car_make = resp.make;
    policy.car_make_id = resp.make_id;
    policy.car_model = resp.model;
    policy.car_model_id = resp.model_id;
    policy.car_year = resp.year;

    // TODO: compute contract type
    policy.contractType = contracts.contractTypes[0];
    cb();
  });
});


module.exports = {
  Policy: mongoose.model('Policy', policySchema),
  CarPolicy: mongoose.model('CarPolicy', carPolicySchema)
};
