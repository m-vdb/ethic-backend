chai = require 'chai'
expect = chai.expect

validator = require 'validator'

RestifyValidator = require '../../ethic/utils/restify-validator.js'


describe 'restify-validator', ->

  beforeEach ->
    @req =
      params:
        key: 'value'
    @v = new RestifyValidator @req, 'key', 'Error msg'

  describe 'constructor', ->

    it 'should set the attributes on the validator', ->
      expect(@v._req).to.be.equal @req
      expect(@req.validationErrors).to.be.like []
      expect(@v._param).to.be.equal 'key'
      expect(@v._value).to.be.equal 'value'
      expect(@v._error_msg).to.be.equal 'Error msg'

  describe 'validator methods', ->
    for own name of validator
      if not (
        typeof validator[name] != 'function' or
        name == 'extend' or
        name == 'init' or
        name.indexOf('to') == 0 # toDate, toFloat, ...
      )
        it 'should have ' + name + ' method binded', ->
          expect(@v[name]).to.be.a 'function'

    it 'should work with methods that accept more than one argument', ->
      expect(@v.isLength 2, 4).to.be.equal @v
      expect(@req.validationErrors).to.be.like ['Error msg']

    it 'should work with simple methods', ->
      expect(@v.isAlpha()).to.be.equal @v
      expect(@req.validationErrors).to.be.like []
      expect(@v.isInt()).to.be.equal @v
      expect(@req.validationErrors).to.be.like ['Error msg']
