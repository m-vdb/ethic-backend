'use strict';
var Grid = require('gridfs-stream'),
    mongoose = require('mongoose');

var gridfs;

module.exports = function () {
  if (!gridfs) {
    gridfs = new Grid(mongoose.connection.db, mongoose.mongo);
  }
  return gridfs;
};
