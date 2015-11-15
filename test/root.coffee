sinon = require 'sinon'
_ = require 'underscore'
mongoose = require 'mongoose'
hippie = require 'hippie'
kue = require 'kue'
config = require 'config'
fs = require 'fs'

JWTStrategy = require '../ethic/auth/jwt.js'
queues = require '../ethic/queues.js'
server = require '../ethic/index.js'

before ->
  if mongoose.connection.readyState == 0
    mongoose.connect config.get('mongoUri'), config.get('mongoOptions')
  @noauth = =>
    @sinon.stub JWTStrategy::, 'authenticate', ->
      this.success {user: 'toto'}
  queues.dumb = kue.createQueue()
  _.each queues, (queue) ->
    queue.testMode.enter()

beforeEach ->
  @sinon = sinon.sandbox.create()
  @api = hippie server
  _this = @
  @api.sendFile = (field, filename, path) =>
    boundary = Math.random()
    data = (
      '--' + boundary + '\r\n' +
      'Content-Disposition: form-data; name="' + field + '"; filename="' + filename + '"\r\n' +
      'Content-Type: image/png\r\n' +
      '\r\n' +
      fs.readFileSync(path) +
      '\r\n--' + boundary + '--'
    )
    _this.api
      .header 'Content-Type', 'multipart/form-data; boundary=' + boundary
      .send data

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
