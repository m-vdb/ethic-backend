var mongoose = require('mongoose'),
    web3 = require('web3');

var contractSchema = new mongoose.Schema({
  address: String,
  name: {type: String, index: {unique: true}},
  abi: Array
}, {
  collection: 'contracts'
});

contractSchema.static({
  getMain: function (cb) {
    return this.findOne({name: 'ethic_main'}, function (err, contract) {
      if (err) cb(err);
      else if (!contract) cb(new Error('Cannot find main contract.'));
      else cb(null, contract.ethereumContract());
    });
  }
});

// TODO:
//  - find a way to bind each method from the eth contract to mongo contract
//  - have a configuration file (enough for now) with gas costs
//  - implement transaction receipt check (while ...)
contractSchema.method({
  ethereumContract: function () {
    return web3.eth.contract(this.abi).at(this.address);
  }
});

module.exports = mongoose.model('Contract', contractSchema);
