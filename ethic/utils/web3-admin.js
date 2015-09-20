var web3 = require('web3');

// FIXME: https://github.com/ethereum/web3.js/pull/288
module.exports = function () {
  web3._extend({
    property: 'personal',
    methods:
    [
      new web3._extend.Method({
        name: 'newAccount',
        call: 'personal_newAccount',
        params: 1,
        inputFormatter: [web3._extend.formatters.formatInputString],
        outputFormatter: web3._extend.formatters.formatOutputString
      }),

      new web3._extend.Method({
        name: 'unlockAccount',
        call: 'personal_unlockAccount',
        params: 3,
        inputFormatter: [
          web3._extend.formatters.formatInputString,
          web3._extend.formatters.formatInputString,
          web3._extend.formatters.formatInputInt
        ],
        outputFormatter: web3._extend.formatters.formatOutputBool
      })
    ],
    properties: []
  });
};
