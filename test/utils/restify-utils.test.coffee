sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

restify = require 'restify'
restifyUtils = require('../../ethic/utils/restify-utils.js')()

describe 'restify-utils', ->
  beforeEach ->
    @sinon = sinon.sandbox.create()
    @req = validationErrors: @sinon.stub()
    @res = send: @sinon.spy()
    @next = @sinon.spy()

  afterEach ->
    @sinon.restore()

  describe 'sendValidationErrorIfAny', ->

    it 'should send validation error if any and return true', ->
      restifyUtils(@req, @res, @next)
      expect(@next).to.have.been.calledWith()
      @req.validationErrors.returns true
      expect(@req.sendValidationErrorIfAny()).to.be.true
      expect(@res.send).to.have.been.calledWithMatch new restify.errors.BadRequestError("Bad parameters.")

    it 'should return false otherwise', ->
      restifyUtils(@req, @res, @next)
      expect(@next).to.have.been.calledWith()
      @req.validationErrors.returns false
      expect(@req.sendValidationErrorIfAny()).to.be.false
      expect(@res.send).to.not.have.been.called
