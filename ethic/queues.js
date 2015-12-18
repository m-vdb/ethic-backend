'use strict';
var kue = require('kue'),
    config = require('config');

module.exports = {
  main: kue.createQueue({
    redis: config.get('redisOptions')
  })
};
