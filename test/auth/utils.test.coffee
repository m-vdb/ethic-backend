chai = require 'chai'
expect = chai.expect
mongoose = require 'mongoose'
jwt = require 'jsonwebtoken'
config = require 'config'

Member = require '../../ethic/models/member.js'
authUtils = require '../../ethic/auth/utils.js'

describe 'authUtils', ->

  describe 'checkMemberPassword', ->
    it 'should return error if user is not in database', (done) ->
      authUtils.checkMemberPassword 'user', 'pass', (err, user, authErr) ->
        expect(err).to.be.null
        expect(user).to.be.false
        expect(authErr).to.be.like message: 'Incorrect credentials.'
        done()

    it 'should return error if user in database but wrong password', (done) ->
      user = new Member
        email: 'user@gmail.com'
        password: 'secret'
        ssn: '007-007-1234'
      user.save (err) =>
        return done(err) if err
        authUtils.checkMemberPassword 'user@gmail.com', 'pass', (err, user, authErr) ->
          expect(err).to.be.null
          expect(user).to.be.false
          expect(authErr).to.be.like message: 'Incorrect credentials.'
          done()

    it 'should return the user if user/password is ok', (done) ->
      user = new Member
        email: 'user2@gmail.com'
        password: 'secret'
        ssn: '007-007-5678'
      user.save (err) =>
        return done(err) if err
        authUtils.checkMemberPassword 'user2@gmail.com', 'secret', (err, user, authErr) ->
          expect(err).to.be.null
          expect(user).to.be.like user
          expect(authErr).to.be.undefined
          done()

    it 'should return error if mongoose error occured', (done) ->
      @sinon.stub mongoose.Query::, 'exec', (cb) -> cb('some error')
      user = new Member
        email: 'user3@gmail.com'
        password: 'secret'
        ssn: '007-007-9012'
      user.save (err) =>
        return done(err) if err
        authUtils.checkMemberPassword 'user3@gmail.com', 'secret', (err, user, authErr) ->
          expect(err).to.be.equal 'some error'
          expect(user).to.be.false
          expect(authErr).to.be.undefined
          done()

  describe 'getJWT', ->
    it 'should return a JWT from uid', ->
      token = authUtils.getJWT '561f35e126ee00815a83884f'
      expect(token).to.be.a.string
      decoded = jwt.verify token, config.get('authSecret'), issuer: 'ethic'
      expect(decoded.uid).to.be.equal '561f35e126ee00815a83884f'
      expect(decoded.iat).to.be.a 'number'

  describe 'verifyJWT', ->
    it 'should return success if no id param on the request', (done) ->
      authUtils.verifyJWT params: {}, {}, (err, auth, info) ->
        expect(err).to.be.null
        expect(auth).to.be.true
        expect(info).to.be.undefined
        done()

    it 'should return success if id corresponds to the one in token', (done) ->
      authUtils.verifyJWT {params: {id: '561f35e126ee00815a83884f'}}, uid: '561f35e126ee00815a83884f', (err, auth, info) ->
        expect(err).to.be.null
        expect(auth).to.be.true
        expect(info).to.be.like _id: '561f35e126ee00815a83884f'
        done()

    it 'should return error if id in token is different from the resource', (done) ->
      authUtils.verifyJWT {params: {id: '561f35e126ee00815a83doihu'}}, uid: '561f35e126ee00815a83884f', (err, auth, info) ->
        expect(err).to.be.null
        expect(auth).to.be.false
        expect(info).to.be.like message: 'Incorrect token uid.'
        done()
