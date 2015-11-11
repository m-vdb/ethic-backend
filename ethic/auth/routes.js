var restify = require('restify'),
    config = require('config');

var utils = require('./utils.js');


module.exports = {
  authenticate: function (req, res, next) {
    req.assert('email', 'Invalid email').notEmpty().isEmail();
    req.assert('password', 'Invalid password').notEmpty();
    if (req.sendValidationErrorIfAny()) return next();

    utils.checkMemberPassword(req.params.email, req.params.password, function (err, user, authErr) {
      if (err) return next(err);
      if (authErr || !user) return next(new restify.errors.UnauthorizedError());

      var token = utils.getJWT(user._id);
      res.setCookie(config.get('cookieName'), token, config.get('cookieOptions'));  // TODO: httpOnly ?

      res.json(user.toJSON());
      return next();
    });
  }
};
