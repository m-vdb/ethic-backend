sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

web3 = require 'web3'
ethUtils = require '../../ethic/utils/eth.js'

describe 'eth', ->
  beforeEach ->
    @sinon = sinon.sandbox.create()

  afterEach ->
    @sinon.restore()

  describe 'createAccount', ->

    beforeEach ->
      @sinon.stub web3.personal, "newAccount", -> '0x007'

    it 'should call web3.personal.newAccount', ->
      expect(ethUtils.createAccount 'callback').to.be.equal '0x007'
      expect(web3.personal.newAccount).to.be.have.been.calledWith 'toto', 'callback'
