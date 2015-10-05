_ = require 'underscore'
mongoose = require 'mongoose'
settings = require '../ethic/settings.js'

before ->
  mongoose.connect 'mongodb://localhost/ethic-test'

after ->
  _.each mongoose.connection.collections, (col, name) ->
    col.drop()
  mongoose.disconnect()
