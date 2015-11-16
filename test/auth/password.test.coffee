chai = require 'chai'
expect = chai.expect

pwUtils = require '../../ethic/auth/password.js'

describe 'passwordUtils', ->

  describe 'hashPassword', ->

    it 'should encrypt the password with our auth secret', ->
      expect(pwUtils.hashPassword 'hello dude').to.be.equal 'd52e05eb7e59eeffc429fbe1d847e353d9daf387891eeeba45eca3ddbf7ca1ff'
