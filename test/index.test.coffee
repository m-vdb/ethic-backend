chai = require 'chai'
expect = chai.expect
restify = require 'restify'
_ = require 'underscore'


describe 'index', ->

  describe 'restify CORS headers', ->

    CORS_HEADERS = [
      'accept', 'accept-version', 'content-type',
      'request-id', 'origin', 'x-api-version',
      'x-request-id', 'cache-control', 'x-requested-with'
    ]

    _.each CORS_HEADERS, (header) ->
      it 'should contain ' + header + ' header', ->
        expect(restify.CORS.ALLOW_HEADERS).to.contain header
