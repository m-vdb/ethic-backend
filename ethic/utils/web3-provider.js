var HookedWeb3Provider = require("hooked-web3-provider");

module.exports = {
  get: function (manager) {
    return new HookedWeb3Provider({
      host: "http://localhost:8545",
      transaction_signer: manager
    });
  }
};
