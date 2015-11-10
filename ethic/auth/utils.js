var jwt = require('jsonwebtoken'),
    config = require('config');

var Member = require('../models/member.js');

module.exports = {
  /**
   * Check a member password in database.
   * Verify that the member exists and that
   * the password is correct.
   */
  checkMemberPassword: function (email, password, done) {
    Member.findOne({email: email}).exec(function (err, user) {
      if (err) {
        return done(err, false);
      }
      if (!user || user.password !== password) {
        return done(null, false, {message: "Incorrect credentials."});
      }
      return done(null, user);
    });
  },

  getJWT: function (uid) {
    return jwt.sign({uid: uid}, config.get('authSecret'), {issuer: 'ethic'});
  },

  verifyJWT: function (req, payload, done) {
    // no id in request params, but cookie here
    // or id in params should be the same
    if (!req.params.id || req.params.id === payload.uid) {
      req.params.id = payload.uid;
      return done(null, true, {id: payload.uid});
    }
    done(null, false, {message: 'Incorrect token uid.'});
  }
};
