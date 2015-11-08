var _ = require('underscore');

var types = {
  "ca": require('./ca.json')
};

module.exports = types;
module.exports.contractTypes = _.keys(types);
