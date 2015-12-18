'use strict';
var restify = require('restify');

var Member = require('../models/member.js'),
    paymentUtils = require('./utils.js');


module.exports = {
  createStripeCustomer: function (req, res, next) {
    req.assert('id', 'Invalid id').isLength(24, 24).isHexadecimal();
    req.assert('stripeToken', 'Invalid Stripe token').isLength(1);
    req.assert('cardLast4', 'Invalid last 4 digits').isLength(4, 4).isInt();
    if (req.sendValidationErrorIfAny()) return next();

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (!member.isActive()) return next(new restify.errors.BadRequestError('Account is not active.'));

      paymentUtils.createCustomer(req.params.stripeToken, member, function (err, customer) {
        if (err) return next(err);

        member.stripeId = customer.id;
        member.stripeCards.addToSet(req.params.cardLast4);
        member.save(function (err) {
          if (err) return next(err);

          res.json({});
          return next();
        });
      });
    });
  }
};
