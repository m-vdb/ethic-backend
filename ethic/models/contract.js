var mongoose = require('mongoose'),
    web3 = require('web3');

var contractSchema = new mongoose.Schema({
  address: String,
  name: {type: String, index: {unique: true}},
  abi: Array
}, {
  collection: 'contracts'
});

contractSchema.statics({
  getMain: function (cb) {
    return this.findOne({name: 'ethic_main'}, function (err, contract) {
      if (err) cb(err);
      else if (!contract) cb(new Error('Cannot find main contract.'));
      else cb(null, web3.eth.contract(contract.abi).at(contract.address));
    });
  }
});

module.exports = mongoose.model('Contract', contractSchema);
