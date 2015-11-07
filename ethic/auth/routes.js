var restify = require('restify');

var utils = require('./utils.js'),
    settings = require('../settings.js');


module.exports = {
  authenticate: function (req, res, next) {
    req.assert('email', 'Invalid email').notEmpty().isEmail();
    req.assert('password', 'Invalid password').notEmpty();
    if (req.sendValidationErrorIfAny()) return next();

    utils.checkMemberPassword(req.params.email, req.params.password, function (err, user, authErr) {
      if (err) return next(err);
      if (authErr || !user) return next(new restify.errors.UnauthorizedError());

      var token = utils.getJWT(user._id);
      res.setCookie(settings.cookieName, token, {secure: true});  // TODO: httpOnly ?

      res.json({});
      return next();
    });
  }
};
