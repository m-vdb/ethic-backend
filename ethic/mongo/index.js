var config = require('config'),
    mongoose = require('mongoose'),
    gridfs = require('./gridfs');

// mongodb needs to be configured before
mongoose.connect(config.get('mongoUri'), config.get('mongoOptions'));

module.exports = {
  gridfs: gridfs()
};
