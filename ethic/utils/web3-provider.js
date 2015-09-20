var web3 = require('web3');

module.exports = {
  _default: null,
  default: function () {
    if (!this._default) {
      this._default = new web3.providers.HttpProvider('http://localhost:8545');
    }
    return this._default;
  }
};
