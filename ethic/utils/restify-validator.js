'use strict';
var validator = require('validator');


var RestifyValidator = function (req, param, error_msg) {
  this._req = req;
  this._param = param;
  if (param.indexOf('files.') === 0) {
    this._param = param.substring(6);
    this._value = this._getValue(req.files);
  }
  else {
    this._value = this._getValue(req.params);
  }
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

RestifyValidator.prototype._getValue = function (params) {
  var paramList = this._param.split('.');
  var value = params;

  try {
    paramList.map(function(item) {
      value = value[item];
    });
    return value;
  }
  catch (e) {
    return null;
  }
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
