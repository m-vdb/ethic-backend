var restify = require('restify');

module.exports = function () {
  return function(req, res, next) {
    req.sendValidationErrorIfAny = function () {
      if (req.validationErrors()) {
        res.send(new restify.errors.BadRequestError("Bad parameters."));
        return true;
      }
      return false;
    }
    return next();
  };
};
