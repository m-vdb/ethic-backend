'use strict';
var config = require('config'),
    stripe = require('stripe')(config.get('stripe.secretKey'));


module.exports = {
  stripe: stripe,
  createCustomer: function (token, member, cb) {
    stripe.customers.create({
      source: token,
      description: member._id.toString()
    }, cb);
  }
};
