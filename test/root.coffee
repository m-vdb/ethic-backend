_ = require 'underscore'
mongoose = require 'mongoose'
hippie = require 'hippie'

settings = require '../ethic/settings.js'
server = require '../ethic/index.js'

before ->
  @api = hippie server
  if mongoose.connection.readyState == 0
    mongoose.connect settings.mongoUri, settings.mongoOptions

after ->
  if mongoose.connection.readyState > 0
    _.each mongoose.connection.collections, (col, name) ->
      col.drop()
    mongoose.disconnect()
