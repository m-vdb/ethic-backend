'use strict';
var passport = require('passport');
var jwt = require('jsonwebtoken');
// FIXME: use passport-jwt package as soon as it's possible to use cookies

var noop = function () {};


class JWTStrategy extends passport.Strategy {
  constructor(options, verify) {
    super();
    this.name = 'jwt';

    this._secretOrKey = options.secretOrKey;
    if (!this._secretOrKey) {
        throw new TypeError('JWTStrategy requires a secret or key');
    }

    this._verify = verify || noop;
    this._cookieName = options.cookieName;
    this._verifyOpts = {};

    if (options.issuer) {
        this._verifyOpts.issuer = options.issuer;
    }
  }

  authenticate (req) {
    var token = this.getToken(req);
    if (!token) {
      return this.fail(new Error("No auth token"));
    }
    this.verify(req, token);
  }

  getToken (req) {
    if (this._cookieName) {
      return req.cookies[this._cookieName];
    }
  }

  verify (req, token) {
    try {
      var payload = jwt.verify(token, this._secretOrKey, this._verifyOpts);
    } catch (jwtErr) {
      return this.fail(jwtErr);
    }

    var self = this;
    var verified = function(err, user, info) {
      if (err) return self.error(err);
      if (!user) return self.fail(info);

      return self.success(user, info);
    };

    try {
      this._verify(req, payload, verified);
    } catch (e) {
      this.error(e);
    }
  }
}

module.exports = JWTStrategy;
