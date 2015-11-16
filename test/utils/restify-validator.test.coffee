chai = require 'chai'
expect = chai.expect

validator = require 'validator'

RestifyValidator = require '../../ethic/utils/restify-validator.js'


describe 'restify-validator', ->

  beforeEach ->
    @req =
      validationErrors: []
      params:
        key: 'value'
    @v = new RestifyValidator @req, 'key', 'Error msg'

  describe 'constructor', ->

    it 'should set the attributes on the validator', ->
      expect(@v._req).to.be.equal @req
      expect(@v._param).to.be.equal 'key'
      expect(@v._value).to.be.equal 'value'
      expect(@v._error_msg).to.be.equal 'Error msg'

    it 'should work with req.files too', ->
      @req.files =
        someFile:
          value: 'yes'
      v = new RestifyValidator @req, 'files.someFile.value', 'Error msg'
      expect(v._req).to.be.equal @req
      expect(v._param).to.be.equal 'someFile.value'
      expect(v._value).to.be.equal 'yes'
      expect(v._error_msg).to.be.equal 'Error msg'

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

  describe '_getValue', ->
    it 'should retrieve a value on the params', ->
      req =
        params:
          key: 'value'
      v = new RestifyValidator req, 'key'
      expect(v._value).to.be.equal 'value'

    it 'should retrieve a nested value on the params', ->
      req =
        params:
          key:
            level2:
              last: 'yop'
      v = new RestifyValidator req, 'key.level2.last'
      expect(v._value).to.be.equal 'yop'

    it 'should catch errors and return null', ->
      req =
        params:
          key: 'value'
      v = new RestifyValidator req, 'dumb.key.nested'
      expect(v._value).to.be.null
