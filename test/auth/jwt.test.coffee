chai = require 'chai'
expect = chai.expect
jwt = require 'jsonwebtoken'

Member = require '../../ethic/models/member.js'
JWTStrategy = require '../../ethic/auth/jwt.js'


describe 'JWTStrategy', ->

  beforeEach ->
    @verify = @sinon.stub()
    @jwt = new JWTStrategy
      secretOrKey: 'the-key'
      issuer: 'ethic-test'
      cookieName: 'the-cookie'
    , @verify

  describe 'constructor', ->
    it 'should initialize properly', ->
      expect(@jwt.name).to.be.equal 'jwt'
      expect(@jwt._secretOrKey).to.be.equal 'the-key'
      expect(@jwt._verify).to.be.equal @verify
      expect(@jwt._cookieName).to.be.equal 'the-cookie'
      expect(@jwt._verifyOpts).to.be.like issuer: 'ethic-test'

    it 'should throw TypeError if missing secret key', ->
      expect(-> new JWTStrategy {}).to.throw TypeError

    it 'should initialize without issuer', ->
      strategy = new JWTStrategy
        secretOrKey: 'the-key'
        cookieName: 'the-cookie'
      , @verify
      expect(strategy.name).to.be.equal 'jwt'
      expect(strategy._secretOrKey).to.be.equal 'the-key'
      expect(strategy._verify).to.be.equal @verify
      expect(strategy._cookieName).to.be.equal 'the-cookie'
      expect(strategy._verifyOpts).to.be.like {}

    it 'should initialize without verify cb', ->
      strategy = new JWTStrategy
        secretOrKey: 'the-key'
        issuer: 'ethic-test'
        cookieName: 'the-cookie'

      expect(strategy.name).to.be.equal 'jwt'
      expect(strategy._secretOrKey).to.be.equal 'the-key'
      expect(strategy._verify).to.be.ok
      expect(strategy._cookieName).to.be.equal 'the-cookie'
      expect(strategy._verifyOpts).to.be.like issuer: 'ethic-test'

  describe 'getToken', ->
    it 'should return the token if cookieName is defined', ->
      expect(@jwt.getToken cookies: {'the-cookie': 'value'}).to.be.equal 'value'

    it 'should return undefined if cookieName is not defined', ->
      strategy = new JWTStrategy
        secretOrKey: 'the-key'
        issuer: 'ethic-test'
      expect(strategy.getToken cookies: {'the-cookie': 'value'}).to.be.undefined

  describe 'authenticate', ->
    it 'should call this.fail if missing token', ->
      @jwt.fail = @sinon.spy()
      @jwt.authenticate cookies: {}
      expect(@jwt.fail).to.have.been.calledWithMatch new Error 'No auth token'

    it 'should call this.verify if token found', ->
      @sinon.stub @jwt, 'verify'
      req = cookies: {'the-cookie': 'some-cookie'}
      @jwt.authenticate req
      expect(@jwt.verify).to.have.been.calledWith req, 'some-cookie'

  describe 'verify', ->
    it 'should call this.fail if token is bad', ->
      @jwt.fail = @sinon.spy()
      @jwt.verify {}, 'value'
      expect(@jwt.fail).to.have.been.called

    it 'should call this._verify if the token is ok', ->
      token = jwt.sign({uid: 'toto'}, 'the-key', issuer: 'ethic-test')
      @jwt.verify {}, token
      expect(@verify).to.have.been.calledWithMatch {}, {uid: 'toto', iss: 'ethic-test'}

    it 'should verify the issuer', ->
      @jwt.fail = @sinon.spy()
      token = jwt.sign({uid: 'toto'}, 'the-key', issuer: 'bad-guy')
      @jwt.verify {}, token
      expect(@jwt.fail).to.have.been.called

    it 'should catch errors from this._verify if any', ->
      @verify.throws()
      @jwt.error = @sinon.spy()
      token = jwt.sign({uid: 'toto'}, 'the-key', issuer: 'ethic-test')
      @jwt.verify {}, token
      expect(@verify).to.have.been.calledWithMatch {}, {uid: 'toto', iss: 'ethic-test'}
      expect(@jwt.error).to.have.been.called

    it 'should call this._verify even if none passed', ->
      strategy = new JWTStrategy
        secretOrKey: 'the-key'
        issuer: 'ethic-test'
        cookieName: 'the-cookie'
      token = jwt.sign({uid: 'toto'}, 'the-key', issuer: 'ethic-test')
      strategy.verify {}, token

    it 'should define final callback that should call error if error', (done) ->
      strategy = new JWTStrategy
        secretOrKey: 'the-key'
        issuer: 'ethic-test'
        cookieName: 'the-cookie'
      , (req, payload, cb) =>
        cb 'some error'
        expect(strategy.error).to.have.been.calledWith 'some error'
        done()

      strategy.error = @sinon.spy()
      token = jwt.sign({uid: 'toto'}, 'the-key', issuer: 'ethic-test')
      strategy.verify {}, token

    it 'should define final callback that should call fail if no user', (done) ->
      strategy = new JWTStrategy
        secretOrKey: 'the-key'
        issuer: 'ethic-test'
        cookieName: 'the-cookie'
      , (req, payload, cb) =>
        cb null, null, missing: 'user'
        expect(strategy.fail).to.have.been.calledWith missing: 'user'
        done()

      strategy.fail = @sinon.spy()
      token = jwt.sign({uid: 'toto'}, 'the-key', issuer: 'ethic-test')
      strategy.verify {}, token

    it 'should define final callback that should call success if user and no error', (done) ->
      strategy = new JWTStrategy
        secretOrKey: 'the-key'
        issuer: 'ethic-test'
        cookieName: 'the-cookie'
      , (req, payload, cb) =>
        cb null, email: 'tom@jerry.com', ok: 'yeah'
        expect(strategy.success).to.have.been.calledWithMatch email: 'tom@jerry.com', ok: 'yeah'
        done()

      strategy.success = @sinon.spy()
      token = jwt.sign({uid: 'toto'}, 'the-key', issuer: 'ethic-test')
      strategy.verify {}, token
