var ethUtil = require('ethereumjs-util'),
    Tx = require('ethereumjs-tx'),
    _ = require('underscore');

var utils = require('./utils.js'),
    Member = require('../models/member.js');


function AccountManager (accountOrprivateKey) {
  if (typeof accountOrprivateKey == 'string')
    this.account = utils.accountFromPrivateKey(privateKey);
  else
    this.account = accountOrprivateKey;
}


_.extend(AccountManager.prototype, {
  hasAddress: function (address, callback) {
    if (!address) {
      return callback(new Error("Unknown address."));
    }
    if (_.contains(address, '0x')) {
      address = address.substring(2);
    }
    Member.findOne({address: address}).then(function (err, member) {
      callback(err, member != null);
    });
  },
  signTransaction: function (tx_params, callback) {
    if(this.account.address != tx_params.from) {
      return callback(new Error("Cannot sign transaction; from address is not the current account."));
    }

    var rawTx = {
      nonce: formatHex(ethUtil.stripHexPrefix(tx_params.nonce)),
      gasPrice: formatHex(ethUtil.stripHexPrefix(tx_params.gasPrice)),
      gasLimit: formatHex(new BigNumber('3141592').toString(16)),  // TODO
      value: '00',
      data: ''
    };

    if (tx_params.gas != null)
      rawTx.gasLimit = formatHex(ethUtil.stripHexPrefix(tx_params.gas));

    if (tx_params.to != null) // TODO check that it's one of our contracts
      rawTx.to = formatHex(ethUtil.stripHexPrefix(tx_params.to));

    if (tx_params.value != null)
      rawTx.value = formatHex(ethUtil.stripHexPrefix(tx_params.value));

    if(tx_params.data != null)
      rawTx.data = formatHex(ethUtil.stripHexPrefix(tx_params.data));

    var privateKey = new Buffer(this.account.privateKey, 'hex');

    // init new transaction object, and sign the transaction
    var tx = new Tx(rawTx);
    tx.sign(privateKey);

    // Build a serialized hex version of the Tx
    var serializedTx = '0x' + tx.serialize().toString('hex');

    callback(null, serializedTx);
  }
});

module.exports = AccountManager;
