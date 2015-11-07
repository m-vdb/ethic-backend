chai = require 'chai'
expect = chai.expect
jwt = require 'jsonwebtoken'

settings = require '../../ethic/settings.js'
Member = require '../../ethic/models/member.js'
authUtils = require '../../ethic/auth/utils.js'


describe 'authRoutes', ->

  beforeEach (done) ->
    @noauth()
    @member = new Member
      ssn: 7027321
      firstName: "Donald"
      lastName: "Trump"
      email: "donaldtrump@asshole.com"
      address: "0x007"
      state: 'active'
      password: 'the-damn-pw'
    @member.save done

  afterEach (done) ->
    @member.remove done

  describe 'authenticate', ->
    it 'should return 400 if bad email', (done) ->
      @api
        .post '/authenticate'
        .json()
        .send
          email: "joeswanson___gmail.com"
          password: 'yop'
        .expectStatus 400
        .end done

    it 'should return 400 if missing password', (done) ->
      @api
        .post '/authenticate'
        .json()
        .send
          email: "joeswanson@gmail.com"
        .expectStatus 400
        .end done

    it 'should return 401 if wrong user / password', (done) ->
      @api
        .post '/authenticate'
        .json()
        .send
          email: "donaldtrump@asshole.com"
          password: 'nfwojwpejdow'
        .expectStatus 401
        .end done

    it 'should return 500 if internal error occured', (done) ->
      @sinon.stub authUtils, 'checkMemberPassword', (u, p, cb) -> cb('some big error')
      @api
        .post '/authenticate'
        .json()
        .send
          email: "donaldtrump@asshole.com"
          password: 'nfwojwpejdow'
        .expectStatus 500
        .end done

    it 'should return 200 and return a cookie if ok', (done) ->
      @api
        .post '/authenticate'
        .json()
        .send
          email: "donaldtrump@asshole.com"
          password: 'the-damn-pw'
        .expectStatus 200
        .end (err, res, body) =>
          return done(err) if err
          # cookie is like set-cookie: 'ethic=***; Secure'
          [cookie, secure] = res.headers['set-cookie'][0].split('; ')
          [cookieName, token] = cookie.split('=')
          expect(secure).to.be.equal 'Secure'
          expect(cookieName).to.be.equal settings.cookieName
          decoded = jwt.verify token, settings.authSecret, issuer: 'ethic'
          expect(decoded.uid).to.be.equal @member._id.toString()
          done()
