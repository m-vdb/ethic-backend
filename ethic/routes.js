var VERSION = '0.0.1';

module.exports = {
  version: VERSION,
  home: function (req, res, next) {
    res.send({
      "name": "ethic",
      "version": VERSION
    });
    return next();
  },
  createUser: function (req, res, next) {
    res.send({});
    return next();
  },
  user: function (req, res, next) {
    res.send({});
    return next();
  },
  acceptUser: function (req, res, next) {
    res.send({});
    return next();
  },
  denyUser: function (req, res, next) {
    res.send({});
    return next();
  },
  userPolicies: function (req, res, next) {
    res.send([]);
    return next();
  },
  createUserPolicy: function (req, res, next) {
    res.send({});
    return next();
  },
  userClaims: function (req, res, next) {
    res.send([]);
    return next();
  },
  createUserClaims: function (req, res, next) {
    res.send({});
    return next();
  }
};
