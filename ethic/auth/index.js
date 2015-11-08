var passport = require('passport');

var JWTStrategy = require('./jwt.js'),
    utils = require('./utils.js'),
    settings = require('../settings.js');


module.exports = {};
module.exports.routes = require('./routes.js');
module.exports.jwt = function () {
  passport.use(new JWTStrategy({
    issuer: 'ethic',
    secretOrKey: settings.authSecret,
    cookieName: settings.cookieName
  }, utils.verifyJWT));

  return passport.authenticate('jwt', {session: false});
};
