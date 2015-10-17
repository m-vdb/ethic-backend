var kue = require('kue');

module.exports = {
  main: kue.createQueue({
    redis: require('./settings').redisOptions
  })
};
