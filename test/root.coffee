sinon = require 'sinon'
_ = require 'underscore'
mongoose = require 'mongoose'
hippie = require 'hippie'

settings = require '../ethic/settings.js'
server = require '../ethic/index.js'

before ->
  if mongoose.connection.readyState == 0
    mongoose.connect settings.mongoUri, settings.mongoOptions

beforeEach ->
  @sinon = sinon.sandbox.create()
  @api = hippie server

afterEach ->
  @sinon.restore()

after ->
  if mongoose.connection.readyState > 0
    _.each mongoose.connection.collections, (col, name) ->
      col.drop()
    mongoose.disconnect()
