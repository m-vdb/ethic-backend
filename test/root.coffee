sinon = require 'sinon'
_ = require 'underscore'
mongoose = require 'mongoose'
hippie = require 'hippie'
kue = require 'kue'

JWTStrategy = require '../ethic/auth/jwt.js'
queues = require '../ethic/queues.js'
settings = require '../ethic/settings.js'
server = require '../ethic/index.js'

before ->
  if mongoose.connection.readyState == 0
    mongoose.connect settings.mongoUri, settings.mongoOptions
  @noauth = =>
    @sinon.stub JWTStrategy::, 'authenticate', ->
      this.success {user: 'toto'}
  queues.dumb = kue.createQueue()
  _.each queues, (queue) ->
    queue.testMode.enter()

beforeEach ->
  @sinon = sinon.sandbox.create()
  @api = hippie server

afterEach ->
  @sinon.restore()
  _.each queues, (queue) ->
    queue.testMode.clear()

after (done) ->
  server.close ->
    _.each queues, (queue) ->
      queue.testMode.exit()
    delete queues.dumb
    if mongoose.connection.readyState > 0
      _.each mongoose.connection.collections, (col, name) ->
        col.drop()
      mongoose.disconnect()
    done()
