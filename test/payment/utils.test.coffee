chai = require 'chai'
expect = chai.expect
Stripe = require 'stripe'

Member = require '../../ethic/models/member.js'
paymentUtils = require '../../ethic/payment/utils.js'


describe 'paymentUtils', ->

  beforeEach (done) ->
    @createStripeCustomer = @sinon.stub paymentUtils.stripe.customers, 'create'

    @member = new Member
      firstName: 'john'
      lastName: 'oliver'
      ssn: '111-222-3333'
      email: 'john@oliver.doh'
      address: '3528175afde786512'
      password: 'coco'
    @member.save done

  describe 'createCustomer', ->

    it 'should call stripe.customers.create with token and description', ->
      cb = ->
      paymentUtils.createCustomer 'card_token', @member, cb
      expect(@createStripeCustomer).to.have.been.calledWith
        source: 'card_token'
        description: @member._id.toString()
      , cb
