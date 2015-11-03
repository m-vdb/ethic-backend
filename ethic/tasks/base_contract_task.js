"use strict";
var BaseTask = require('./base.js');
var contracts = require('../models/contract.js').contracts;

class BaseContractTask extends BaseTask {
  static delay (data, queue, cb) {
    this.ensureContract(data);
    return super.delay(data, queue, cb);
  }

  static ensureContract (data) {
    var contract = contracts[data.contractType];
    if (!contract)  throw new Error('Invalid contract type.');
    return contract;
  }

  run (data, cb) {
    this.contract = BaseContractTask.ensureContract(data);
    return super.run(data, cb);
  }
}

module.exports = BaseContractTask;
