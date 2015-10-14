var _ = require('underscore');


module.exports = {
  version: '0.0.1',
  mongoUri: 'mongodb://localhost/ethic',
  mongoOptions: {},
  contractTypes: _.keys(require('./contracts'))
};
