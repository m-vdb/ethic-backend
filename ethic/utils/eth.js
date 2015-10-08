var web3 = require('web3'),
    _ = require('underscore');


var ethUtils = module.exports = {
  createAccount: function (cb) {
    return web3.personal.newAccount('toto', cb);  // TODO: passphrase
  },
  extractCallback: function (args) {
    if (_.isFunction(args[args.length - 1])) return args.pop();
    return _.noop;
  },
  getOptions: function () {
    return {from: web3.eth.accounts[0]};
  },
  formatOutput: function (value, outputsConfig) {
    if (_.isArray(value)) {  // works for structs
      var obj = {};
      _.each(value, function (val, index) {
        obj[outputsConfig[index].name] = this.formatOutput(val, [outputsConfig[index]]);
      }, this);
      return obj;
    }

    if (_.isObject(value)) {
      return value.c[0];  // works with uint
    }

    if (outputsConfig && outputsConfig.length) {
      // strings
      if (outputsConfig[0].type == 'bytes') return web3.toAscii(value);
    }
    // address and default
    return value;
  },
  blockUntilTransactionDone: function (txHash, cb) {
    var receipt, waited = 0, maxWait = 20;
    var interval = setInterval(function () {
      if (waited < maxWait && !(receipt = web3.eth.getTransactionReceipt(txHash))) {
        waited++;
      }
      else {
        clearInterval(interval);
        cb(receipt ? null : 'Cannot get transaction receipt.', receipt);
      }
    }, 1000)
  },
  makeMethod: function (contract, abi) {
    return function () {
      var args = Array.prototype.slice.call(arguments),
          cb = ethUtils.extractCallback(args),
          options = ethUtils.getOptions();
      options.gas = abi.gas || 1000000;

      args.push(options);
      args.push(function (err, txHash) {
        if (err) return cb(err);
        ethUtils.blockUntilTransactionDone(txHash, function (err, txReceipt) {
          if (err) return cb(err);

          return cb(txReceipt.cumulativeGasUsed >= options.gas ? 'Transaction ran out of gas.' : null);
        });
      });

      return contract[abi.name].apply(contract, args);
    };
  },
  makeAccessor: function (contract, abi) {
    return function () {
      var value = contract[abi.name].apply(contract, arguments);
      return ethUtils.formatOutput(value, abi.outputs);
    };
  }
};
