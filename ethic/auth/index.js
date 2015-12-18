'use strict';
var passport = require('passport'),
    config = require('config');

var JWTStrategy = require('./jwt.js'),
    utils = require('./utils.js');


module.exports = {};
module.exports.routes = require('./routes.js');
module.exports.jwt = function () {
  passport.use(new JWTStrategy({
    issuer: 'ethic',
    secretOrKey: config.get('authSecret'),
    cookieName: config.get('cookieName')
  }, utils.verifyJWT));

  return passport.authenticate('jwt', {session: false});
};
