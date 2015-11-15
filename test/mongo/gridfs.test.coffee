chai = require 'chai'
expect = chai.expect
gridFs = require '../../ethic/mongo/gridfs'


describe 'gridfs', ->

  describe 'gridfs', ->

    it 'should return the same instance all the time', ->
      expect(gridFs()).to.be.equal gridFs()
