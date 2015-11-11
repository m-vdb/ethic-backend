chai = require 'chai'
expect = chai.expect
ObjectId = require('mongoose').Types.ObjectId
config = require 'config'

cars = require '../ethic/utils/cars.js'
queues = require '../ethic/queues.js'
Member = require '../ethic/models/member.js'
policies = require '../ethic/models/policy.js'
AddMemberPolicyTask = require('../ethic/tasks').AddMemberPolicyTask
Policy = policies.Policy
CarPolicy = policies.CarPolicy

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
    @sinon.stub cars, 'decodeVin', (vin, cb) ->
      cb null,
        year: 2000,
        model: 'Roadster'
        model_id: 'roadster'
        make: 'Tesla'
        make_id: 'tesla'

  afterEach (done) ->
    @member.remove done

  describe 'home', ->
    it 'should yield 200 and return the version', (done) ->
      @api
        .get '/'
        .json()
        .expectStatus 200
        .expectBody
          name: 'ethic'
          version: config.get 'version'
        .end done

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
          password: 'yop'
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
          password: 'yop'
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
          password: 'yop'
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
          password: 'yop'
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
          password: 'yop'
        .expectStatus 200
        .end (err, res, body) ->
          done(err) if err
          expect(body.id).to.be.ok
          Member.findOne _id: body.id, (err, member) ->
            done(err) if err
            expect(member._id.equals body.id).to.be.true
            expect(member.ssn).to.be.equal "35219836210"
            expect(member.firstName).to.be.equal "Joe"
            expect(member.lastName).to.be.equal "Swanson"
            expect(member.email).to.be.equal "joeswanson@gmail.com"
            expect(member.state).to.be.equal "new"
            expect(member.password).to.be.equal "yop"
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
          password: 'yop'
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

    it 'should return 400 if member id desnt have the right length', (done) ->
      @api
        .get '/members/000000'
        .json()
        .expectStatus 400
        .end done

    it 'should return 400 if member id is invalid', (done) ->
      @api
        .get '/members/dayum'
        .json()
        .expectStatus 400
        .end done

    it 'should return 200 with the right body otherwise', (done) ->
      @api
        .get '/members/' + @member._id.toString()
        .json()
        .expectStatus 200
        .expectBody
          id: @member._id.toString()
          ssn: '7027321'
          firstName: "Donald"
          lastName: "Trump"
          email: "donaldtrump@asshole.com"
          address: "0x007"
          state: 'active'
          contractTypes: []
        .end done

  describe 'acceptMember', ->
    it 'should return 404 if member does not exist', (done) ->
      @api
        .post '/members/000000000000000000000000/accept'
        .json()
        .expectStatus 404
        .end done

    it 'should return 400 if member id desnt have the right length', (done) ->
      @api
        .post '/members/000000/accept'
        .json()
        .expectStatus 400
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
        done(err) if err
        @api
          .post '/members/' + @member._id.toString() + '/accept'
          .json()
          .expectStatus 200
          .expectBody {}
          .end (err, res, body) =>
            done(err) if err
            Member.findOne _id: @member._id, (err, member) ->
              done(err) if err
              expect(member.state).to.be.equal 'active'
              done()

  describe 'denyMember', ->

    it 'should return 404 if member does not exist', (done) ->
      @api
        .post '/members/000000000000000000000000/deny'
        .json()
        .expectStatus 404
        .end done

    it 'should return 400 if member id desnt have the right length', (done) ->
      @api
        .post '/members/000000/deny'
        .json()
        .expectStatus 400
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
        done(err) if err
        @api
          .post '/members/' + @member._id.toString() + '/deny'
          .json()
          .expectStatus 200
          .expectBody {}
          .end (err, res, body) =>
            done(err) if err
            Member.findOne _id: @member._id, (err, member) ->
              done(err) if err
              expect(member.state).to.be.equal 'denied'
              done()

  describe 'memberPolicies', ->
    beforeEach (done) ->
      @policy = new Policy
        member: @member._id
        initial_premium: 5000
        initial_deductible: 50000
      @policy.save done

    afterEach (done) ->
      @policy.remove done

    it 'should return 404 if member does not exist', (done) ->
      @api
        .get '/members/000000000000000000000000/policies'
        .json()
        .expectStatus 404
        .end done

    it 'should return 400 if member id desnt have the right length', (done) ->
      @api
        .get '/members/000000/policies'
        .json()
        .expectStatus 400
        .end done

    it 'should return 400 if member id is invalid', (done) ->
      @api
        .get '/members/dayum/policies'
        .json()
        .expectStatus 400
        .end done

    it 'should return 400 if account is not active', (done) ->
      @member.state = 'new'
      @member.save (err) =>
        done(err) if err

        @api
          .get '/members/' + @member._id.toString() + '/policies'
          .json()
          .expectStatus 400
          .expectBody
            code: 'BadRequestError'
            message: 'Account is not active.'
          .end done

    it 'should return a 400 if couldnt retrieve policies', (done) ->
      @sinon.stub Member::, 'getPolicies', (cb) -> cb('cannot get policies')
      @api
        .get '/members/' + @member._id.toString() + '/policies'
        .json()
        .expectStatus 500
        .end done

    it 'should return a list of policies otherwise', (done) ->
      @api
        .get '/members/' + @member._id.toString() + '/policies'
        .json()
        .expectStatus 200
        .expectBody [
          {
            id: @policy._id.toString(),
            member: @member._id.toString(),
            initial_premium: 5000,
            initial_deductible: 50000
          }
        ]
        .end done

  describe 'createMemberPolicy', ->

    it 'should return 400 if member id desnt have the right length', (done) ->
      @api
        .post '/members/000000/policies'
        .json()
        .expectStatus 400
        .end done

    it 'should return 400 if member id is invalid', (done) ->
      @api
      .post '/members/dayum/policies'
      .json()
      .expectStatus 400
      .end done

    it 'should return 400 if policy type is invalid', (done) ->
      @api
      .post '/members/' + @member._id.toString() + '/policies'
      .json()
      .send
        type: 'BikePolicy'
        contractType: 'ca'
      .expectStatus 400
      .end done

    it 'should return 400 if contractType is invalid', (done) ->
      @api
      .post '/members/' + @member._id.toString() + '/policies'
      .json()
      .send
        type: 'CarPolicy'
        contractType: 'wa'
      .expectStatus 400
      .end done

    it 'should return 400 if cannot load Policy model', (done) ->
      @sinon.stub Policy, 'getPolicyTypes', -> ['CarPolicy', 'BikePolicy']
      @api
      .post '/members/' + @member._id.toString() + '/policies'
      .json()
      .send
        type: 'BikePolicy'
        contractType: 'ca'
      .expectStatus 400
      .expectBody
        code: 'BadRequestError'
        message: 'Bad policy type.'
      .end done

    it 'should return 404 if cannot find member', (done) ->
      @api
      .post '/members/000000000000000000000000/policies'
      .json()
      .send
        type: 'CarPolicy'
        contractType: 'ca'
      .expectStatus 404
      .end done

    it 'should return 400 if member is not active', (done) ->
      @member.state = 'new'
      @member.save (err) =>
        done(err) if err
        @api
        .post '/members/' + @member._id.toString() + '/policies'
        .json()
        .send
          type: 'CarPolicy'
          contractType: 'ca'
        .expectStatus 400
        .expectBody
          code: 'BadRequestError'
          message: 'Account is not active.'
        .end done

    it 'should return 400 if policy didnt validate', (done) ->
      @api
      .post '/members/' + @member._id.toString() + '/policies'
      .json()
      .send
        type: 'CarPolicy'
        contractType: 'ca'  # missing VIN
      .expectStatus 400
      .expectBody
          code: 'BadRequestError'
          message: 'Missing car VIN.'
      .end done

    it 'should return 200 if it managed to create task', (done) ->
      @api
      .post '/members/' + @member._id.toString() + '/policies'
      .json()
      .send
        type: 'CarPolicy'
        contractType: 'ca'
        car_vin: 'ABCDEF1234567890Y'
      .expectStatus 200
      .end (err, res, body) =>
        done(err) if err

        expect(queues.main.testMode.jobs.length).to.be.equal 1
        job = queues.main.testMode.jobs[0]
        expect(job.type).to.be.equal 'AddMemberPolicyTask'
        expect(job.data).to.be.like
          contractType: 'ca'
          policyId: body.id
        CarPolicy.findOne _id: body.id, (err, policy) ->
          done(err) if err
          done(if policy then null else new Error('policy not saved'))

    it 'should return 500 if there was an issue while creating the task', (done) ->
      @sinon.stub AddMemberPolicyTask, 'delay', (data, cb) -> cb('Error, dude')
      @api
      .post '/members/' + @member._id.toString() + '/policies'
      .json()
      .send
        type: 'CarPolicy'
        contractType: 'ca'
        car_vin: 'ABCDEF1234567890Y'
      .expectStatus 500
      .end done

  describe 'memberClaims', ->
    it 'should be dummy', (done) ->
      @api
        .get '/members/toto/claims'
        .expectStatus 200
        .end done

  describe 'createMemberClaims', ->
    it 'should be dummy', (done) ->
      @api
        .post '/members/toto/claims'
        .expectStatus 200
        .end done
