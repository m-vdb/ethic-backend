chai = require 'chai'
expect = chai.expect

pwUtils = require '../../ethic/auth/password.js'

describe 'passwordUtils', ->

  describe 'hashPassword', ->

    it 'should encrypt the password with our auth secret', ->
      expect(pwUtils.hashPassword 'hello dude').to.be.equal 'd52e05eb7e59eeffc429fbe1d847e353d9daf387891eeeba45eca3ddbf7ca1ff'

  describe 'checkPassword', ->

    it 'should return true if password matches the hash', ->
      expect(pwUtils.checkPassword 'd52e05eb7e59eeffc429fbe1d847e353d9daf387891eeeba45eca3ddbf7ca1ff', 'hello dude').to.be.true

    it 'should return false if password doesnt match the hash', ->
      expect(pwUtils.checkPassword 'd52e05eb7e59eeffc429fbe1d847e353d9daf387891eeeba45eca3ddbf7ca1ff', 'hello dud').to.be.false
