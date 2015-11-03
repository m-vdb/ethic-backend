'use strict';
var BaseContractTask = require('./base_contract_task.js'),
    Policy = require('../models/policy.js').Policy;


class AddMemberPolicyTask extends BaseContractTask {
  process (data, cb) {
    var _this = this;
    Policy.findOne({_id: data.policyId}).populate('member').exec(function (err, policy) {
      if (err) return cb(err);
      if (!policy) return cb(new Error('Cannot find policy'));

      var member = policy.member;

      function finalCallback (err) {
        if (err) return cb(err);

        member.addContractType(policy.contractType, cb);
      }

      
      // if member doesnt have an account on the specific contract
      if (!member.hasContract(policy.contractType)) {
        // member already has an ethereum account
        if (member.address) {
          _this.contract.create_member(member.address, 1, finalCallback);
        }
        // if member has no address, then create it in ehtereum
        else {
          _this.contract.new_member(function (err, address) {
            if (err) return cb(err);

            member.address = address;
            finalCallback();
          });
        }
      }
      // in this case member already has an account on the specific contract
      else {
        _this.contract.add_policy(member.address, finalCallback);
      }
    });
  }
}


module.exports = AddMemberPolicyTask;
