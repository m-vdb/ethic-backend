var restify = require('restify');

var RestifyValidator = require('./restify-validator.js');

module.exports = function () {
  return function(req, res, next) {

    req.hasValidationErrors = function () {
      return req.validationErrors && req.validationErrors.length > 0;
    };

    req.sendValidationErrorIfAny = function () {
      if (req.hasValidationErrors()) {
        res.send(new restify.errors.BadRequestError("Bad parameters."));
        return true;
      }
      return false;
    };

    req.assert = function (param, msg) {
      req.validationErrors = req.validationErrors || [];
      return new RestifyValidator(req, param, msg);
    };

    return next();
  };
};
