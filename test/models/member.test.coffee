chai = require 'chai'
expect = chai.expect

Member = require '../../ethic/models/member.js'
CarPolicy = require('../../ethic/models/policy.js').CarPolicy
Claim = require '../../ethic/models/claim.js'
cars = require '../../ethic/utils/cars.js'

describe 'Member', ->
  beforeEach (done) ->
    @sinon.stub cars, 'decodeVin', (vin, cb) ->
      cb null,
        year: 2000,
        model: 'Roadster'
        model_id: 'roadster'
        make: 'Tesla'
        make_id: 'tesla'

    @member = new Member
      firstName: 'john'
      lastName: 'oliver'
      ssn: '111-222-3333'
      email: 'john@oliver.doh'
      address: '3528175afde786512'
      password: 'coco'
      stripeId: 'some-id'
      stripeCards: ['1234', '5678']
    @member.save done

  afterEach (done) ->
    @member.remove done

  describe 'isNotNew', ->
    it 'should return true if member is not new', ->
      @member.state = 'active'
      expect(@member.isNotNew()).to.be.true

    it 'should return false if member is new', ->
      expect(@member.isNotNew()).to.be.false

  describe 'isActive', ->
    it 'should return true if member is active', ->
      @member.state = 'active'
      expect(@member.isActive()).to.be.true

    it 'should return false if member is not active', ->
      expect(@member.isActive()).to.be.false

  describe 'activate', ->
    it 'should set state to active and save the member', (done) ->
      @member.activate =>
        Member.findOne {_id: @member._id}, (err, doc) ->
          throw err if err
          throw 'cannot find member' if not doc
          expect(doc.state).to.be.equal 'active'
          done()

  describe 'deny', ->
    it 'should set state to denied and save the member', (done) ->
      @member.deny =>
        Member.findOne {_id: @member._id}, (err, doc) ->
          throw err if err
          throw 'cannot find member' if not doc
          expect(doc.state).to.be.equal 'denied'
          done()

  describe 'getPolicies', ->
    it 'should return empty array if no policies', (done) ->
      @member.getPolicies (err, policies) ->
        expect(err).to.be.null
        expect(policies).to.be.like []
        done()

    it 'should return a list of policies otherwise', (done) ->
      @policy = new CarPolicy
        member: @member._id
        initial_premium: 10000
        initial_deductible: 100000
        car_vin: 'UDUEOWIJEOWE12345'
      @policy.save (err) =>
        throw err if err
        @member.getPolicies (err, policies) =>
          expect(err).to.be.null
          expect(policies).to.have.length 1
          expect(policies[0].toJSON()).to.be.like @policy.toJSON()
          @policy.remove done

  describe 'getClaims', ->
    it 'should return empty array if no claims', (done) ->
      @member.getClaims (err, claims) ->
        expect(err).to.be.null
        expect(claims).to.be.like []
        done()

    it 'should return a list of claims otherwise', (done) ->
      @policy = new CarPolicy
        member: @member._id
        initial_premium: 10000
        initial_deductible: 100000
        car_vin: 'UDUEOWIJEOWE12345'
      @policy.save (err) =>
        throw err if err
        @claim = new Claim
          member: @member._id
          policy: @policy._id
          description: 'Something bad and looooooooooooooooooooong enough.'
          date: new Date()
          location: 'Paris'
        @claim.save (err) =>
          throw err if err
          @member.getClaims (err, claims) =>
            expect(err).to.be.null
            expect(claims).to.have.length 1
            expect(claims[0].toJSON()).to.be.like @claim.toJSON()
            @claim.remove done

  describe 'hasContract', ->
    it 'should return true if member is already on contract', ->
      @member.contractTypes = ['ca']
      expect(@member.hasContract 'ca').to.be.true

    it 'should return false if not', ->
      @member.contractTypes = ['ca']
      expect(@member.hasContract 'or').to.be.false

  describe 'addContractType', ->
    it 'should not add the contract type if already here', (done) ->
      @member.contractTypes = ['ca']
      @member.addContractType 'ca', =>
        expect(@member.contractTypes).to.be.like ['ca']
        done()

    it 'should not add the contract type if already here', (done) ->
      @member.contractTypes = ['ca']
      @member.addContractType 'wa', =>
        expect(@member.contractTypes).to.be.like ['ca', 'wa']
        done()

  describe 'preSave', ->

    it 'should return error if password is missing', (done) ->
      member = new Member
        firstName: 'john'
        lastName: 'doe'
        ssn: '111-222-4444'
        email: 'john@doe.doe'
      member.save (err) ->
        expect(err).to.be.like new Error('Missing password.')
        done()

    it 'should hash password and continue to save the member', (done) ->
      member = new Member
        firstName: 'john'
        lastName: 'doe'
        ssn: '111-222-4444'
        email: 'john@doe.doe'
        password: 'a password'
      member.save (err) ->
        return done(err) if err
        expect(member.password).to.be.equal 'f81cd6e542b4f272d06510e461439b25053fae87535ff83a4e4e185633b72ac1'
        member.remove done

    it 'should not do a thing if the member is not new', (done) ->
      member = new Member
        firstName: 'john'
        lastName: 'doe'
        ssn: '111-222-4444'
        email: 'john@doe.doe'
        password: 'a password'
      member.save (err) ->
        return done(err) if err
        expect(member.password).to.be.equal 'f81cd6e542b4f272d06510e461439b25053fae87535ff83a4e4e185633b72ac1'
        member.firstName = 'John'
        member.save (err) ->
          return done(err) if err
          # didn't change
          expect(member.password).to.be.equal 'f81cd6e542b4f272d06510e461439b25053fae87535ff83a4e4e185633b72ac1'
          member.remove done

  describe 'toJSON', ->

    it 'should ignore sensitive values', ->
      json = @member.toJSON()
      expect(json._id).to.be.undefined
      expect(json.__v).to.be.undefined
      expect(json.ssn).to.be.undefined
      expect(json.password).to.be.undefined
      expect(json.stripeId).to.be.undefined

    it 'should serialize the other values', ->
      expect(@member.toJSON()).to.be.like
        id: @member._id.toString()
        firstName: 'john'
        lastName: 'oliver'
        email: 'john@oliver.doh'
        address: '3528175afde786512'
        stripeCards: ['1234', '5678']
        contractTypes: []
        state: 'new'
