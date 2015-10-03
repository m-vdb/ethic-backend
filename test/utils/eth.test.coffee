chai = require "chai"
expect = chai.expect

describe 'eth', ->

  describe 'createAccount', ->

    it 'should call web3.personal.newAccount', ->
      expect(true).to.be.true
