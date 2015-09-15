var restify = require('restify'),
    web3 = require('web3');

var settings = require('./settings.js'),
    accountUtils = require('./accounts/utils.js'),
    AccountManager = require('./accounts/manager.js'),
    Member = require('./models/member.js'),
    web3Provider = require('./utils/web3-provider.js');

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

    var errors = req.validationErrors();
    if (errors) {
      res.send(new restify.errors.BadRequestError("Bad parameters."));
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
    // TODO (Mongo): return user former premium/deductible
    res.send({});
    return next();
  },
  /**
   * Accept a member. This is called after a background
   * check came back positive.
   */
  acceptMember: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').notEmpty().isHexadecimal();

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (member.isNotNew()) next(new restify.errors.BadRequestError('Account is not new.'));

      // create an ethereum account and bind the address on the member
      var account = accountUtils.createAccount();
      member.address = account.address;
      member.save(function (err) {
        if (err) return next(err);

        var manager = new AccountManager(account);
        web3.setProvider(web3Provider.get(manager));
        // TODO: create member on contract
        member.activate();
        // TODO: maybe encrypt it or encode it
        // TODO: fix strange format
        res.send({privateKey: account.privateKey});
        return next();
      });
    });
  },
  /**
   * Deny a member. This is called after a background
   * check came back negative.
   */
  denyMember: function (req, res, next) {
    // TODO (Mongo):
    // - update member data in mongo (flag that he has been denied)
    res.send({});
    return next();
  },
  /**
   * List all the member policies.
   */
  memberPolicies: function (req, res, next) {
    // TODO (Ethereum):
    // - retrieve a list of all the member's policies
    res.send([]);
    return next();
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
