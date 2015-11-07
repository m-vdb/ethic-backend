var jwt = require('jsonwebtoken');

var Member = require('../models/member.js'),
    settings = require('../settings.js');

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
    return jwt.sign({uid: uid}, settings.authSecret, {issuer: 'ethic'});
  }
};
