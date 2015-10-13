var mongoose = require('mongoose');
require('mongoose-schema-extend');

var policySchema = new mongoose.Schema({
  member: {type: mongoose.Schema.Types.ObjectId, ref: 'Member'},
  initial_premium: Number,
  initial_deductible: Number
}, {
  collection: 'policies',
  discriminatorKey: '_type'
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
  }
});

var carPolicySchema = policySchema.extend({
  car_year: {type: Number, required: true, min: 1950, max: new Date().getFullYear()},
  car_make: {type: String, required: true},  // TODO: module shared between front and back
  car_model: {type: String, required: true}  // TODO: module shared between front and back
});


module.exports = {
  Policy: mongoose.model('Policy', policySchema),
  CarPolicy: mongoose.model('CarPolicy', carPolicySchema)
};
