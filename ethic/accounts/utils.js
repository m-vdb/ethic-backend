var web3 = require('web3');


module.exports = {
  unlock: function (address) {
    console.log('unlocking ', address);
    if (!web3.personal.unlockAccount(address, 'toto')) { // TODO: passphrase
      throw new Error('Cannot unlock account ' + address);
    }
  },
  createAccount: function (cb) {
    return web3.personal.newAccount('toto', cb);  // TODO: passphrase
  }
};
