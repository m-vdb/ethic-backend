sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

ObjectId = require('mongoose').Types.ObjectId
settings = require '../ethic/routes.js'
Member = require '../ethic/models/member.js'
contract = require('../ethic/models/contract.js').main

describe 'routes', ->

  beforeEach (done) ->
    @noauth()
    @member = new Member
      ssn: 7027321
      firstName: "Donald"
      lastName: "Trump"
      email: "donaldtrump@asshole.com"
      address: "0x007"
      state: 'active'
    @member.save done

  afterEach (done) ->
    @member.remove done

  describe 'createMember', ->
    it 'should yield 400 if nothing passed', (done) ->
      @api
        .post '/members'
        .json()
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done

    it 'should yield 400 if invalid ssn', (done) ->
      @api
        .post '/members'
        .json()
        .send
          ssn: "sigeiqwuge"
          firstName: "Joe"
          lastName: "Swanson"
          email: "joeswanson@gmail.com"
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done

    it 'should yield 400 if invalid firstName', (done) ->
      @api
        .post '/members'
        .json()
        .send
          ssn: "35219836210"
          firstName: "Joe_-*&*(%&$@!&"
          lastName: "Swanson"
          email: "joeswanson@gmail.com"
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done
    it 'should yield 400 if invalid lastName', (done) ->
      @api
        .post '/members'
        .json()
        .send
          ssn: "35219836210"
          firstName: "Joe"
          lastName: "Swanson_^)*!^@_!&@_"
          email: "joeswanson@gmail.com"
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done

    it 'should yield 400 if invalid email', (done) ->
      @api
        .post '/members'
        .json()
        .send
          ssn: "35219836210"
          firstName: "Joe"
          lastName: "Swanson"
          email: "joeswanson___gmail.com"
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done

    it 'should save a new member', (done) ->
      @api
        .post '/members'
        .json()
        .send
          ssn: "35219836210"
          firstName: "Joe"
          lastName: "Swanson"
          email: "joeswanson@gmail.com"
        .expectStatus 200
        .end (err, res, body) ->
          throw err if err
          expect(body.id).to.be.ok
          Member.findOne _id: body.id, (err, member) ->
            throw err if err
            expect(member._id.equals body.id).to.be.true
            expect(member.ssn).to.be.equal "35219836210"
            expect(member.firstName).to.be.equal "Joe"
            expect(member.lastName).to.be.equal "Swanson"
            expect(member.email).to.be.equal "joeswanson@gmail.com"
            expect(member.state).to.be.equal "new"
            done()

    it 'should return error if couldnt save member', (done) ->
      @sinon.stub Member::, 'save', (cb) -> cb('the badass error')
      @api
        .post '/members'
        .json()
        .send
          ssn: "35219836210"
          firstName: "Joe"
          lastName: "Swanson"
          email: "joeswanson@gmail.com"
        .expectStatus 500
        .expectBody
          code: 'InternalError'
          message: ''
        .end done

  describe 'member', ->
    it 'should return 404 if member does not exist', (done) ->
      @api
        .get '/members/000000000000000000000000'
        .json()
        .expectStatus 404
        .end done

    it 'should return 400 if member id is invalid', (done) ->
      @api
        .get '/members/dayum'
        .json()
        .expectStatus 400
        .end done

    it 'should return 200 with the right body otherwise', (done) ->
      @sinon.stub contract, 'members', -> {key: 'value', yeah: 'bro'}
      @api
        .get '/members/' + @member._id.toString()
        .json()
        .expectStatus 200
        .expectBody
          _id: @member._id.toString()
          __v: 0
          ssn: '7027321'
          firstName: "Donald"
          lastName: "Trump"
          email: "donaldtrump@asshole.com"
          address: "0x007"
          state: 'active'
          contract:
            key: 'value'
            yeah: 'bro'
        .end done

  describe 'acceptMember', ->
    it 'should return 404 if member does not exist', (done) ->
      @api
        .post '/members/000000000000000000000000/accept'
        .json()
        .expectStatus 404
        .end done

    it 'should return 400 if member id is invalid', (done) ->
      @api
        .post '/members/dayum/accept'
        .json()
        .expectStatus 400
        .end done

    it 'should return 400 if account is not new', (done) ->
      @api
        .post '/members/' + @member._id.toString() + '/accept'
        .json()
        .expectStatus 400
        .expectBody
          code: 'BadRequestError'
          message: 'Account is not new.'
        .end done

    it 'should return 200 and set member to active otherwise', (done) ->
      @member.state = 'new'
      @member.save (err) =>
        throw err if err
        @api
          .post '/members/' + @member._id.toString() + '/accept'
          .json()
          .expectStatus 200
          .expectBody {}
          .end (err, res, body) =>
            throw err if err
            Member.findOne _id: @member._id, (err, member) ->
              throw err if err
              expect(member.state).to.be.equal 'active'
              done()

  describe 'denyMember', ->

    it 'should return 404 if member does not exist', (done) ->
      @api
        .post '/members/000000000000000000000000/deny'
        .json()
        .expectStatus 404
        .end done

    it 'should return 400 if member id is invalid', (done) ->
      @api
        .post '/members/dayum/deny'
        .json()
        .expectStatus 400
        .end done

    it 'should return 400 if account is not new', (done) ->
      @api
        .post '/members/' + @member._id.toString() + '/deny'
        .json()
        .expectStatus 400
        .expectBody
          code: 'BadRequestError'
          message: 'Account is not new.'
        .end done

    it 'should return 200 and set member to denied otherwise', (done) ->
      @member.state = 'new'
      @member.save (err) =>
        throw err if err
        @api
          .post '/members/' + @member._id.toString() + '/deny'
          .json()
          .expectStatus 200
          .expectBody {}
          .end (err, res, body) =>
            throw err if err
            Member.findOne _id: @member._id, (err, member) ->
              throw err if err
              expect(member.state).to.be.equal 'denied'
              done()
