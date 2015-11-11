var validator = require('validator');


var RestifyValidator = function (req, param, error_msg) {
  this._req = req;
  this._req.validationErrors = [];
  this._param = param;
  this._value = req.params[param];
  this._error_msg = error_msg;
};

RestifyValidator.bindMethod = function (func) {
  RestifyValidator.prototype[name] = function () {
    var args = Array.prototype.slice.call(arguments);
    args.splice(0, 0, this._value);
    if (!func.apply(null, args)) {
      this._req.validationErrors.push(this._error_msg);
    }

    return this;
  };
};

for (var name in validator) {
  if (
    typeof validator[name] !== 'function' ||
    name === 'extend' ||
    name === 'init' ||
    name.indexOf('to') === 0 // toDate, toFloat, ...
  ) {
    continue;
  }

  RestifyValidator.bindMethod(validator[name]);
}


module.exports = RestifyValidator;
