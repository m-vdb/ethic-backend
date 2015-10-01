var web3 = require('web3');


module.exports = {
  createAccount: function (cb) {
    return web3.personal.newAccount('toto', cb);  // TODO: passphrase
  }
};
