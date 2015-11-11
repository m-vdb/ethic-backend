chai = require 'chai'
expect = chai.expect

restify = require 'restify'
restifyUtils = require('../../ethic/utils/restify.js')()
RestifyValidator = require '../../ethic/utils/restify-validator'


describe 'restify-utils', ->
  beforeEach ->
    @req = params: {}
    @res = send: @sinon.spy()
    @next = @sinon.spy()
    restifyUtils(@req, @res, @next)

  describe 'sendValidationErrorIfAny', ->

    it 'should send validation error if any and return true', ->
      expect(@next).to.have.been.calledWith()
      @req.validationErrors = ['error']
      expect(@req.sendValidationErrorIfAny()).to.be.true
      expect(@res.send).to.have.been.calledWithMatch new restify.errors.BadRequestError("Bad parameters.")

    it 'should return false otherwise', ->
      expect(@next).to.have.been.calledWith()
      expect(@req.sendValidationErrorIfAny()).to.be.false
      expect(@res.send).to.not.have.been.called

  describe 'hasValidationErrors', ->
    it 'should return false if validationErrors is not set on the request', ->
      expect(@req.hasValidationErrors()).to.be.not.ok

    it 'should return false if validationErrors is empty', ->
      @req.validationErrors = []
      expect(@req.hasValidationErrors()).to.be.not.ok

    it 'should return true if validationErrors is not empty', ->
      @req.validationErrors = ['error']
      expect(@req.hasValidationErrors()).to.be.ok

  describe 'assert', ->
    it 'should init validationErrors array and return an instance of RestifyValidator', ->
      validator = @req.assert 'param', 'Some error'
      expect(validator).to.be.an.instanceof RestifyValidator
      expect(@req.validationErrors).to.be.like []
      expect(validator._req).to.be.equal @req
      expect(validator._param).to.be.equal 'param'
      expect(validator._error_msg).to.be.equal 'Some error'

      validationErrors = @req.validationErrors
      # no override
      validator = @req.assert 'param2', 'Some error'
      expect(@req.validationErrors).to.be.equal validationErrors
