sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

Member = require '../../ethic/models/member.js'
cars = require '../../ethic/utils/cars.js'
AddMemberPolicyTask = require('../../ethic/tasks').AddMemberPolicyTask
policies = require '../../ethic/models/policy.js'
contracts = require '../../ethic/models/contract.js'
Contract = contracts.Contract
contracts = contracts.contracts
CarPolicy = policies.CarPolicy


describe 'AddMemberPolicyTask', ->

  beforeEach (done) ->
    @sinon.stub cars, 'decodeVin', (vin, cb) ->
      cb null,
        year: 2000,
        model: 'Roadster'
        model_id: 'roadster'
        make: 'Tesla'
        make_id: 'tesla'

    @task = new AddMemberPolicyTask()
    @member = new Member
      ssn: 7027321
      firstName: "Donald"
      lastName: "Trump"
      email: "donaldtrump@asshole.com"
      address: "0x007"
      state: 'active'
      password: 'dayum'
    @member.save (err) =>
      return done(err) if err

      @policy = new CarPolicy
        member: @member
        contractType: 'ca'
        car_vin: 'ABCDEF1234567890Y'
      @policy.save done

  afterEach (done) ->
    @member.remove done

  describe 'run', ->

    it 'should simply add the policy if member was already on contract', (done) ->
      @sinon.stub contracts.ca, 'add_policy', (addr, cb) -> cb()
      @member.contractTypes = ['ca']
      @member.address = '0x007'
      @member.save (err) =>
        return done(err) if err

        @task.run
          contractType: 'ca'
          policyId: @policy.id.toString()
        , (err) ->
          done(err) if err
          expect(contracts.ca.add_policy).to.have.been.calledWithMatch '0x007'
          done()

    it 'should not create a new address if member had one', (done) ->
      @sinon.stub contracts.ca, 'create_member', (addr, count, cb) -> cb()
      @member.address = '0x007'
      @member.save (err) =>
        return done(err) if err

        @task.run
          contractType: 'ca'
          policyId: @policy.id.toString()
        , (err) ->
          done(err) if err
          expect(contracts.ca.create_member).to.have.been.calledWithMatch '0x007', 1
          done()

    it 'should create address + member if member had no address', (done) ->
      @sinon.stub contracts.ca, 'new_member', (cb) -> cb(null, '0x008')
      @member.address = null
      @member.save (err) =>
        return done(err) if err

        @task.run
          contractType: 'ca'
          policyId: @policy.id.toString()
        , (err) =>
          return done(err) if err
          expect(contracts.ca.new_member).to.have.been.called
          Member.findOne _id: @member._id, (err, member) ->
            throw 'error' if err or not member
            expect(member.address).to.be.equal '0x008'
            expect(member.contractTypes).to.be.like ['ca']
            done()

    it 'should return error if couldnt create new member', (done) ->
      @sinon.stub contracts.ca, 'new_member', (cb) -> cb('dayum', '0x009')
      @member.address = null
      @member.save (err) =>
        return done(err) if err

        @task.run
          contractType: 'ca'
          policyId: @policy.id.toString()
        , (err) =>
          expect(err).to.be.equal 'dayum'
          expect(contracts.ca.new_member).to.have.been.called
          Member.findOne _id: @member._id, (err, member) ->
            throw 'error' if err or not member
            expect(member.address).to.be.null
            done()

    it 'should return error if couldnt create member or add policy on ethereum', (done) ->
      @sinon.stub contracts.ca, 'create_member', (addr, count, cb) -> cb('oops')
      @member.address = '0x007'
      @member.save (err) =>
        return done(err) if err

        @task.run
          contractType: 'ca'
          policyId: @policy.id.toString()
        , (err) =>
          expect(err).to.be.equal 'oops'
          expect(contracts.ca.create_member).to.have.been.calledWithMatch '0x007', 1
          done()

    it 'should return error if couldnt save the contract type on the member', (done) ->
      @sinon.stub contracts.ca, 'new_member', (cb) -> cb(null, '0x008')
      @sinon.stub Member::, 'addContractType', (t, cb) -> cb('oups')
      @member.address = null
      @member.save (err) =>
        return done(err) if err

       @task.run
        contractType: 'ca'
        policyId: @policy.id.toString()
      , (err) ->
        expect(err).to.be.equal 'oups'
        done()

    it 'should return error if couldnt find the policy', (done) ->
      @task.run
        contractType: 'ca'
        policyId: '000000000000000000000000'
      , (err) ->
        expect(err).to.be.like new Error('Cannot find policy')
        done()

    it 'should return error if an error occurred during the query', (done) ->
      @task.run
        contractType: 'ca'
        policyId: 12
      , (err) ->
        expect(err.message).to.be.equal 'Cast to ObjectId failed for value "12" at path "_id"'
        done()
