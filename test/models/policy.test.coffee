chai = require 'chai'
expect = chai.expect
mongoose = require 'mongoose'

policies = require '../../ethic/models/policy.js'

describe 'Policy', ->

  describe 'modelFromType', ->
    it 'should return the right type if exists', ->
      expect(policies.Policy.modelFromType('CarPolicy')).to.be.equal mongoose.model('CarPolicy')

    it 'should throw error otherwise', ->
      expect(-> policies.Policy.modelFromType('PoolPolicy')).to.throw 'Unknown policy type: PoolPolicy'
