sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect
mongoose = require 'mongoose'

settings = require '../ethic/settings.js'
ApiUser = require '../ethic/models/api_user.js'

describe 'auth', ->

  describe 'basic', ->
    it 'should return 401 if no auth is passed', (done) ->
      @api
        .get '/'
        .expectStatus 401
        .end (err, res, body) ->
          throw err if err
          done()

    it 'should return 401 if user is not in database', (done) ->
      @api
        .get '/'
        .auth 'user', 'pass'
        .expectStatus 401
        .end (err, res, body) ->
          throw err if err
          done()

    it 'should return 401 if user in database but wrong password', (done) ->
      user = new ApiUser
        username: 'user'
        password: 'secret'
      user.save (err) =>
        throw err if err
        @api
          .get '/'
          .auth 'user', 'pass'
          .expectStatus 401
          .end (err, res, body) ->
            throw err if err
            done()

    it 'should return 200 if user/password is ok', (done) ->
      user = new ApiUser
        username: 'user2'
        password: 'secret'
      user.save (err) =>
        throw err if err
        @api
          .get '/'
          .json()
          .auth 'user2', 'secret'
          .expectStatus 200
          .expectBody
            name: 'ethic'
            version: settings.version
          .end (err, res, body) ->
            throw err if err
            done()

    it 'should return 401 if mongoose error occured', (done) ->
      @sinon.stub mongoose.Query::, 'exec', (cb) -> cb('some error')
      user = new ApiUser
        username: 'user3'
        password: 'secret'
      user.save (err) =>
        throw err if err
        @api
          .get '/'
          .auth 'user3', 'secret'
          .expectStatus 401
          .end (err, res, body) ->
            throw err if err
            done()
