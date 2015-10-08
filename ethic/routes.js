var restify = require('restify'),
    web3 = require('web3'),
    _ = require('underscore');

var settings = require('./settings.js'),
    ethUtils = require('./utils/eth.js'),
    Member = require('./models/member.js'),
    contract = require('./models/contract.js');

module.exports = {
  home: function (req, res, next) {
    res.send({
      "name": "ethic",
      "version": settings.version
    });
    return next();
  },
  /**
   * Create a member. We save the member secret data
   * in our database. Doesn't mean the member is accepted,
   * a background check needs to run.
   */
  createMember: function (req, res, next) {
    req.assert('ssn', 'Invalid ssn').notEmpty().isInt();
    req.assert('firstName', 'Invalid firstName').notEmpty().isAlpha();
    req.assert('lastName', 'Invalid lastName').notEmpty().isAlpha();
    req.assert('email', 'Invalid email').notEmpty().isEmail();
    if (req.sendValidationErrorIfAny()) {
      return next();
    }

    var member = new Member({
      ssn: req.params.ssn,
      firstName: req.params.firstName,
      lastName: req.params.lastName,
      email: req.params.email,
    });
    member.save(function (err) {
      if (err) {
        return next(err);
      }
      res.send({
        id: member._id
      });
      return next();
    });
  },
  /**
   * Get member data.
   */
  member: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').notEmpty().isHexadecimal();
    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      // FIXME: do we want to check active or not?
      res.send(_.extend(member.toJSON(), {
        contract: contract.members(member.address)
      }));
      return next();
    });
  },
  /**
   * Accept a member. This is called after a background
   * check came back positive.
   */
  acceptMember: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').notEmpty().isHexadecimal();
    if (req.sendValidationErrorIfAny()) {
      return next();
    }

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (member.isNotNew()) return next(new restify.errors.BadRequestError('Account is not new.'));

      // create an ethereum account and bind the address on the member
      var account = ethUtils.createAccount(function (err, address) {
        if (err) return next(err);

        console.log("created account", address);
        member.address = address;
        member.save(function (err) {
          if (err) return next(err);

          // we do this call using our primary account, not the member's
          console.log('method: ', contract.create_member);
          contract.create_member(address, function (err) {
            if (err) return next(err);

            member.activate(function (err) {
              if (err) return next(err);

              res.send({address: address});
              next();
            });
          });
        });
      });
    });
  },
  /**
   * Deny a member. This is called after a background
   * check came back negative.
   */
  denyMember: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').notEmpty().isHexadecimal();
    if (req.sendValidationErrorIfAny()) {
      return next();
    }

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (member.isNotNew()) return next(new restify.errors.BadRequestError('Account is not new.'));

      member.deny(function (err) {
        res.send({});
        next(err);
      });
    });
  },
  /**
   * List all the member policies.
   */
  memberPolicies: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').notEmpty().isHexadecimal();
    if (req.sendValidationErrorIfAny()) {
      return next();
    }

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (!member.isActive()) return next(new restify.errors.BadRequestError('Account is not active.'));

      // TODO
    });
  },
  /**
   * Create a member policy.
   */
  createMemberPolicy: function (req, res, next) {
    // TODO (Ethereum):
    // - create a policy on ethereum contract
    // - return the policy data
    res.send({});
    return next();
  },
  /**
   * List all the member claims.
   */
  memberClaims: function (req, res, next) {
    // TODO (Ethereum):
    // - retrieve a list of all the member's claims
    res.send([]);
    return next();
  },
  /**
   * Create a member claim.
   */
  createMemberClaims: function (req, res, next) {
    // TODO (Ethereum):
    // - create a claim on ethereum contract
    // - return the claim data
    res.send({});
    return next();
  }
};
