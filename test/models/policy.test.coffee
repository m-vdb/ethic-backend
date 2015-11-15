chai = require 'chai'
expect = chai.expect
mongoose = require 'mongoose'
path = require "path"

gridFs = require('../../ethic/mongo').gridfs
policies = require '../../ethic/models/policy.js'
cars = require '../../ethic/utils/cars.js'
PROOF_OF_INSURANCE = path.normalize(__dirname + '/../data/proof-of-insurance.png')

describe 'Policy', ->

  describe 'modelFromType', ->
    it 'should return the right type if exists', ->
      expect(policies.Policy.modelFromType('CarPolicy')).to.be.equal mongoose.model('CarPolicy')

    it 'should throw error otherwise', ->
      expect(-> policies.Policy.modelFromType('PoolPolicy')).to.throw 'Unknown policy type: PoolPolicy'

    it 'should re-throw error if another error occured', ->
      @sinon.stub mongoose, 'model', -> throw 'boom'
      expect(-> policies.Policy.modelFromType('HummerPolicy')).to.throw 'boom'

  describe 'getPolicyTypes', ->
    it 'should return a list of policy types', ->
      expect(policies.Policy.getPolicyTypes()).to.be.like ['CarPolicy']

  describe 'saveProofOfInsurance', ->

    beforeEach ->
      @policy = new policies.Policy()

    it 'should save a file in gridfs and save its id on the policy', (done) ->
      file =
        path: PROOF_OF_INSURANCE
        type: 'image/png'
      @policy.saveProofOfInsurance file, (err) =>
        expect(err).to.be.null
        expect(@policy.proofId).to.match /[0-9a-f]{24}/
        gridFs.findOne _id: @policy.proofId, (err, file) =>
          done(err) if err
          done('missing file') unless file
          expect(file.filename).to.match new RegExp('proof_[0-9]+_' + @policy._id + '.png')
          expect(file.contentType).to.be.equal 'image/png'
          done()


describe 'CarPolicy', ->

  describe 'pre(save)', ->
    it 'should return error if missing car VIN', (done) ->
      policy = new policies.CarPolicy()
      policy.save (err) ->
        expect(err).to.be.like new Error('Missing car VIN.')
        done()

    it 'should return error if couldnt decode VIN', (done) ->
      @sinon.stub cars, 'decodeVin', (vin, cb) ->
        cb(new Error 'Boom')
      policy = new policies.CarPolicy
        car_vin: '2A4GP54L06R601288'
      policy.save (err) ->
        expect(cars.decodeVin).to.have.been.calledWithMatch '2A4GP54L06R601288'
        expect(err).to.be.like new Error('Boom')
        done()

    it 'should save VIN decoded information otherwise', (done) ->
      @sinon.stub cars, 'decodeVin', (vin, cb) ->
        cb null,
          make: 'Toyota'
          make_id: 'toyota'
          model: 'Corolla'
          model_id: 'corolla'
          year: 2015
      policy = new policies.CarPolicy
        car_vin: '2A4GP54L06R601288'
      policy.save (err) ->
        expect(cars.decodeVin).to.have.been.calledWithMatch '2A4GP54L06R601288'
        expect(err).to.be.null
        expect(policy.toJSON()).to.be.like
          _type: 'CarPolicy'
          contractType: 'ca'
          id: policy._id.toString()
          car_vin: '2A4GP54L06R601288'
          car_make: 'Toyota'
          car_make_id: 'toyota'
          car_model: 'Corolla'
          car_model_id: 'corolla'
          car_year: 2015
        policy.remove done

    it 'shouldnt call decodeVin if the policy is not new', (done) ->
      @sinon.stub cars, 'decodeVin', (vin, cb) ->
        cb null,
          make: 'Toyota'
          make_id: 'toyota'
          model: 'Corolla'
          model_id: 'corolla'
          year: 2015
      policy = new policies.CarPolicy
        car_vin: '2A4GP54L06R601288'
      policy.save (err) ->
        expect(cars.decodeVin).to.have.been.calledWithMatch '2A4GP54L06R601288'
        expect(err).to.be.null
        policy.car_year = 2000
        cars.decodeVin.reset()
        policy.save ->
          expect(cars.decodeVin).to.have.not.been.called
          done()
