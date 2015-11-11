var restify = require('restify'),
    web3 = require('web3'),
    _ = require('underscore'),
    config = require('config');

var ethUtils = require('./utils/eth.js'),
    Member = require('./models/member.js'),
    Policy = require('./models/policy.js').Policy,
    AddMemberPolicyTask = require('./tasks').AddMemberPolicyTask;


module.exports = {
  home: function (req, res, next) {
    res.json({
      name: "ethic",
      version: config.get('version')
    });
    return next();
  },
  /**
   * Create a member. We save the member secret data
   * in our database. Doesn't mean the member is accepted,
   * a background check needs to run.
   */
  createMember: function (req, res, next) {
    req.assert('ssn', 'Invalid ssn').isLength(1).isInt();
    req.assert('firstName', 'Invalid firstName').isLength(1).isAlpha();
    req.assert('lastName', 'Invalid lastName').isLength(1).isAlpha();
    req.assert('email', 'Invalid email').isLength(1).isEmail();
    req.assert('password', 'Invalid password').isLength(1);
    if (req.sendValidationErrorIfAny()) return next();

    var member = new Member({
      ssn: req.params.ssn,
      firstName: req.params.firstName,
      lastName: req.params.lastName,
      email: req.params.email,
      password: req.params.password
    });
    member.save(function (err) {
      if (err) return next(err);

      res.json({
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
    req.assert('id', 'Invalid id').isLength(1).isHexadecimal();
    if (req.sendValidationErrorIfAny()) return next();

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);

      res.json(member.toJSON());
      return next();
    });
  },
  /**
   * Accept a member. This is called after a background
   * check came back positive.
   */
  acceptMember: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').isLength(1).isHexadecimal();
    if (req.sendValidationErrorIfAny()) return next();

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (member.isNotNew()) return next(new restify.errors.BadRequestError('Account is not new.'));

      member.activate(function (err) {
        res.json({});
        next(err);
      });
    });
  },
  /**
   * Deny a member. This is called after a background
   * check came back negative.
   */
  denyMember: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').isLength(1).isHexadecimal();
    if (req.sendValidationErrorIfAny()) return next();

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (member.isNotNew()) return next(new restify.errors.BadRequestError('Account is not new.'));

      member.deny(function (err) {
        res.json({});
        next(err);
      });
    });
  },
  /**
   * List all the member policies.
   */
  memberPolicies: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').isLength(1).isHexadecimal();
    if (req.sendValidationErrorIfAny()) {
      return next();
    }

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (!member.isActive()) return next(new restify.errors.BadRequestError('Account is not active.'));

      member.getPolicies(function (err, policies) {
        if (err) return next(err);

        res.json(_.map(policies, function (policy) {
          return policy.toJSON();
        }));
        next();
      });
    });
  },
  /**
   * Create a member policy.
   */
  createMemberPolicy: function (req, res, next) {
    // TODO: upgrade .isLength(24, 24) not available
    req.assert('id', 'Invalid id').isLength(1).isHexadecimal();
    req.assert('type', 'Invalid type').isLength(1).isIn(Policy.getPolicyTypes());
    if (req.sendValidationErrorIfAny()) return next();

    // get policy model class
    try {
      var PolicyModel = Policy.modelFromType(req.params.type);
    }
    catch (e) {
      return next(new restify.errors.BadRequestError('Bad policy type.'));
    }

    req.getDocumentOr404(Member, {_id: req.params.id}, function (err, member) {
      if (err) return next(err);
      if (!member.isActive()) return next(new restify.errors.BadRequestError('Account is not active.'));

      var policy = new PolicyModel(_.extend(req.params, {member: member._id}));
      policy.save(function (err) {
        if (err) return next(new restify.errors.BadRequestError(err.message));

        AddMemberPolicyTask.delay({
          contractType: policy.contractType,
          policyId: policy._id.toString()
        }, function (err) {
          if (err) return next(err);

          res.json({id: policy._id});
          next();
        });
      });
    });
  },
  /**
   * List all the member claims.
   */
  memberClaims: function (req, res, next) {
    // TODO (Ethereum):
    // - retrieve a list of all the member's claims
    res.json([]);
    return next();
  },
  /**
   * Create a member claim.
   */
  createMemberClaims: function (req, res, next) {
    // TODO (Ethereum):
    // - create a claim on ethereum contract
    // - return the claim data
    res.json({});
    return next();
  }
};
