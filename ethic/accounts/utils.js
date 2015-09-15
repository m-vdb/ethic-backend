var randomBytes = require('secure-random-bytes'),
    ethUtil = require('ethereumjs-util');


module.exports = {
  accountFromPrivateKey: function (privateKey) {
    if (! privateKey instanceof Buffer) {
      privateKey = new Buffer(privateKey, 'hex');
    }
    var publicKey = ethUtil.privateToPublic(privateKey).toString('hex');
    var address = ethUtil.publicToAddress(publicKey).toString('hex');
    privateKey = privateKey.toString('hex');

    return {
      address: address,
      privateKey: privateKey,
      publicKey: publicKey,
      hash: ethUtil.sha3(publicKey + privateKey).toString('hex')
    };
  },
  createAccount: function () {
    var privateKey = randomBytes(64);
    return this.accountFromPrivateKey(privateKey);
  }
};
