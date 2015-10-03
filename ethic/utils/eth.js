var web3 = require('web3'),
    _ = require('underscore');


module.exports = {
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
        obj[outputsConfig[index].name] = this.formatOutput(val);
      }, this);
      return obj;
    }

    if (_.isObject(value)) return value.c[0];  // works with uint
    return value;  // works with addresses
  },
  blockUntilTransactionDone: function (txHash, cb) {
    console.log('block');
    var receipt, waited = 0, maxWait = 20;
    var interval = setInterval(function () {
      if (waited < maxWait && !(receipt = web3.eth.getTransactionReceipt(txHash))) {
        console.log('in while');
        waited++;
      }
      else {
        clearInterval(interval);
        console.log('receipt', receipt);
        cb(receipt ? null : 'Cannot get transaction receipt.', receipt);
      }
    }, 1000)
  },
  makeMethod: function (contract, abi) {
    return function () {
      console.log('in method', arguments);
      var args = Array.prototype.slice.call(arguments);
          cb = ethUtils.extractCallback(args),
          options = ethUtils.getOptions();
      options.gas = abi.gas || 1000000;

      args.push(options);
      args.push(function (err, txHash) {
        console.log('in cb');
        if (err) return cb(err);
        ethUtils.blockUntilTransactionDone(txHash, function (err, txReceipt) {
          if (err) return cb(err);

          return cb(txReceipt.cumulativeGasUsed > options.gas ? 'Transaction ran out of gas.' : null);
        });
      });

      console.log('calling method', args);
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
