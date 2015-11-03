chai = require 'chai'
expect = chai.expect

EdmundsClient = require 'node-edmunds-api'
carUtils = require '../../ethic/utils/cars.js'

describe 'cars', ->

  describe 'decodeVin', ->
    it 'should return error immediately if any', (done) ->
      carUtils.decodeVin null, (err, resp) ->
        expect(err).to.be.like new Error('Parameter vin is required')
        expect(resp).to.be.undefined
        done()

    it 'should return the response from EdmundsClient for valid VIN', (done) ->
      @sinon.stub EdmundsClient::, 'decodeVin', (data, cb) ->
        cb null,
          make:
            name: 'Chrysler'
            niceName: 'chrysler'
          model:
            name: 'Town and Country'
            niceName: 'town-and-country'
          years: [{year: 2006}]
          categories:
            vehicleSize: 'Large'
            vehicleStyle: 'Passenger Minivan'

      carUtils.decodeVin vin: '2A4GP54L06R610288', (err, resp) ->
        expect(err).to.be.null
        expect(resp).be.like
          make: 'Chrysler'
          make_id: 'chrysler'
          model: 'Town and Country'
          model_id: 'town-and-country'
          year: 2006
          size: 'Large'
          style: 'Passenger Minivan'
        done()
