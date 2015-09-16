var mongoose = require('mongoose');

var contractSchema = new mongoose.Schema({
  address: String,
  name: {type: String, index: {unique: true}},
  abi: Array
}, {
  collection: 'contracts'
});

contractSchema.statics({
  getMain: function (cb) {
    return this.findOne({name: 'ethic_main'}, cb);
  }
});

module.exports = mongoose.model('Contract', contractSchema);
