var _ = require('underscore'),
    mongoose = require('mongoose'),
    web3 = require('web3');

var ethUtils = require('../utils/eth.js');

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
      else cb(null, contract.attachAbi());
    });
  }
});

// TODO: add gas costs in database
contractSchema.method({
  ethereumContract: function () {
    return web3.eth.contract(this.abi).at(this.address);
  },

  attachAbi: function () {
    _.each(this.abi, function (abi) {
      var method, methodName;
      if (abi.constant) {  // accessor
        method = ethUtils.makeAccessor(abi);
        methodName = 'get_' + abi.name;
        // remove 's' for plurals, 'members' becomes 'getMember'
        if (methodName[methodName.length - 1] == 's') methodName = methodName.substring(0, methodName.length - 2);
      }
      else {  // contract method
        method = ethUtils.makeMethod(abi);
        methodName = abi.name;
      }
      this[methodName] = method;  // prototype?
      _.bind(method, this);
    }, this)
    return this;
  }
});

module.exports = mongoose.model('Contract', contractSchema);
