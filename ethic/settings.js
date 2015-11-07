var _ = require('underscore');


module.exports = {
  version: '0.0.1',
  authSecret: 'i-am-a-secret-yeah',
  cookieName: 'ethic',  // TODO: this should depend on the env
  mongoUri: 'mongodb://localhost/ethic',
  mongoOptions: {},
  contractTypes: _.keys(require('./contracts')),
  redisOptions: {
    port: 6379,
    host: '127.0.0.1'
  },
  // TODO: have a system for settings
  edmunds: {
    apiKey: 'p4dhmf4sc2qgmukyydu7xtxg'
  }
};
