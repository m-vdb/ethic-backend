var settings = require('./settings.js');

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
    // TODO (Mongo):
    // - check that data is enough
    // - save member in member collection
    res.send({});
    return next();
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
    // TODO (Mongo + Ethereum):
    // - create member on ethereum
    // - update member data in mongo (address + flag that he has been accepted)
    // - return private key
    res.send({});
    return next();
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
