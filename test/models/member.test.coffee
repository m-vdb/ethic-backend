chai = require 'chai'
expect = chai.expect

Member = require '../../ethic/models/member.js'
CarPolicy = require('../../ethic/models/policy.js').CarPolicy

describe 'Member', ->
  beforeEach (done) ->
    @member = new Member
      firstName: 'john'
      lastName: 'oliver'
      ssn: '111-222-3333'
      email: 'john@oliver.doh'
      address: '3528175afde786512'
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
        car_year: 2000,
        car_model: 'roadster'
        car_make: 'tesla'
      @policy.save (err) =>
        throw err if err
        @member.getPolicies (err, policies) =>
          expect(err).to.be.null
          expect(policies).to.have.length 1
          expect(policies[0].toJSON()).to.be.like @policy.toJSON()
          @policy.remove done

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
