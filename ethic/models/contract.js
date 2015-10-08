var _ = require('underscore'),
    web3 = require('web3');

var contractData = require('../data/contract.json'),
    ethUtils = require('../utils/eth.js');

function Contract (data) {
  _.extend(this, data);
  this._attachAbi();
}

// TODO: add gas costs?
_.extend(Contract.prototype, {
  ethereumContract: function () {
    return web3.eth.contract(this.abi).at(this.address);
  },

  _attachAbi: function () {
    var contract = this.ethereumContract();
    _.each(this.abi, function (abi) {
      var factory = abi.constant ? ethUtils.makeAccessor : ethUtils.makeMethod,
          method = factory(contract, abi),
          methodName = abi.name;

      Contract.prototype[methodName] = method;
    }, this)
    return this;
  }
});

var main = new Contract(contractData);

module.exports = main;
