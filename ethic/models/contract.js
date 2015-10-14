var _ = require('underscore'),
    web3 = require('web3');

var contractData = require('../contracts'),
    ethUtils = require('../utils/eth.js');

function Contract (data) {
  _.extend(this, data);
  this._contract = this.ethereumContract();
  this._attachAbi();
}

// TODO: add gas costs?
_.extend(Contract.prototype, {
  ethereumContract: function () {
    return web3.eth.contract(this.abi).at(this.address);
  },

  _attachAbi: function () {
    _.each(this.abi, function (abi) {
      var factory = abi.constant ? ethUtils.makeAccessor : ethUtils.makeMethod,
          method = factory(this._contract, abi),
          methodName = abi.name;

      Contract.prototype[methodName] = method;
    }, this)
    return this;
  },

  new_member: function (cb) {
    var contract = this;
    // we do this call using our primary account
    ethUtils.createAccount(function (err, address) {
      if (err) return cb(err);

      contract.create_member(address, 1, function (err) {
        cb(err, address);
      });
    });
  }
});

module.exports = {
  Contract: Contract,
  contracts: {}
};

_.each(contractData, function (data, name) {
  module.exports.contracts[name] = new Contract(data);
});
