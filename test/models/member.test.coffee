chai = require 'chai'
expect = chai.expect

Member = require '../../ethic/models/member.js'

describe 'Member', ->
  beforeEach (done) ->
    @member = new Member
      firstName: 'john'
      lastName: 'oliver'
      ssn: '111-222-3333'
      email: 'john@oliver.doh'
      address: '3528175afde786512'
    @member.save (err) =>
      throw err if err
      done()

  afterEach (done) ->
    @member.remove done

  describe 'isNotNew', ->
    it 'should return true if member is not new', ->
      @member.state = 'active'
      expect(@member.isNotNew()).to.be.true

    it 'should return false if member is new', ->
      expect(@member.isNotNew()).to.be.false

  describe 'isActive', ->
    it 'should return true if member is active', ->
      @member.state = 'active'
      expect(@member.isActive()).to.be.true

    it 'should return false if member is not active', ->
      expect(@member.isActive()).to.be.false

  describe 'activate', ->
    it 'should set state to active and save the member', (done) ->
      @member.activate =>
        Member.findOne {_id: @member._id}, (err, doc) ->
          throw err if err
          throw 'cannot find member' if not doc
          expect(doc.state).to.be.equal 'active'
          done()

  describe 'deny', ->
    it 'should set state to denied and save the member', (done) ->
      @member.deny =>
        Member.findOne {_id: @member._id}, (err, doc) ->
          throw err if err
          throw 'cannot find member' if not doc
          expect(doc.state).to.be.equal 'denied'
          done()
