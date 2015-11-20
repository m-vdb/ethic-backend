chai = require 'chai'
expect = chai.expect

Member = require '../../ethic/models/member.js'
paymentUtils = require '../../ethic/payment/utils.js'


describe 'paymentRoutes', ->

  beforeEach (done) ->
    @noauth()
    @member = new Member
      ssn: 7027321
      firstName: "Donald"
      lastName: "Trump"
      email: "donaldtrump@asshole.com"
      address: "0x007"
      state: 'active'
      password: 'doh'
    @member.save done

  afterEach (done) ->
    @member.remove done

  describe 'createStripeCustomer', ->
    it 'should return 400 if wrong id', (done) ->
      @api
        .post '/members/toto/stripe-customer'
        .json()
        .send
          stripeToken: "tok"
          cardLast4: "1234"
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done

    it 'should return 400 if no stripe token', (done) ->
      @api
        .post '/members/' + @member._id.toString() + '/stripe-customer'
        .json()
        .send
          stripeToken: ""
          cardLast4: "1234"
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done

    it 'should return 400 if bad card digits', (done) ->
      @api
        .post '/members/' + @member._id.toString() + '/stripe-customer'
        .json()
        .send
          stripeToken: "tok"
          cardLast4: "12341"
        .expectStatus 400
        .expectBody
          code: "BadRequestError"
          message: "Bad parameters."
        .end done

    it 'should return 404 if missing member', (done) ->
      @api
        .post '/members/000000000000000000000000/stripe-customer'
        .json()
        .send
          stripeToken: "tok"
          cardLast4: "1234"
        .expectStatus 404
        .end done

    it 'should return 400 if member is not active', (done) ->
      @member.state = 'new'
      @member.save (err) =>
        return done(err) if err
        @api
          .post '/members/' + @member._id.toString() + '/stripe-customer'
          .json()
          .send
            stripeToken: "tok"
            cardLast4: "1234"
          .expectStatus 400
          .expectBody
            code: "BadRequestError"
            message: "Account is not active."
          .end done

    it 'should return 500 if issue while creating customer', (done) ->
      @sinon.stub paymentUtils, 'createCustomer', (t, m, cb) -> cb('boom', null)
      @api
        .post '/members/' + @member._id.toString() + '/stripe-customer'
        .json()
        .send
          stripeToken: "tok"
          cardLast4: "1234"
        .expectStatus 500
        .end done

    it 'should return 500 if could not save member', (done) ->
      @sinon.stub paymentUtils, 'createCustomer', (t, m, cb) -> cb(null, id: 'stripe_customer_id')
      @sinon.stub Member::, 'save', (cb) -> cb('boom again')
      @api
        .post '/members/' + @member._id.toString() + '/stripe-customer'
        .json()
        .send
          stripeToken: "tok"
          cardLast4: "1234"
        .expectStatus 500
        .end done

    it 'should return 200 and save the right fields on the member if everything went well', (done) ->
      @sinon.stub paymentUtils, 'createCustomer', (t, m, cb) -> cb(null, id: 'stripe_customer_id')
      @api
        .post '/members/' + @member._id.toString() + '/stripe-customer'
        .json()
        .send
          stripeToken: "tok"
          cardLast4: "1234"
        .expectStatus 200
        .end (err, res, body) =>
          return done(err) if err
          Member.findOne _id: @member._id, (err, member) =>
            return done(err) if err
            expect(member.stripeId).to.be.equal 'stripe_customer_id'
            expect(member.stripeCards).to.be.like ['1234']
            done()

    it 'should return 200 and handle multiple card numbers', (done) ->
      @sinon.stub paymentUtils, 'createCustomer', (t, m, cb) -> cb(null, id: 'stripe_customer_id')
      @member.stripeCards.set 0, '1234'
      @member.save (err) =>
        return done(err) if err
        @api
          .post '/members/' + @member._id.toString() + '/stripe-customer'
          .json()
          .send
            stripeToken: "tok"
            cardLast4: "5678"
          .expectStatus 200
          .end (err, res, body) =>
            return done(err) if err
            Member.findOne _id: @member._id, (err, member) =>
              return done(err) if err
              expect(member.stripeId).to.be.equal 'stripe_customer_id'
              expect(member.stripeCards).to.be.like ['1234', '5678']
              done()

    it 'should return 200 and make sure the card is not duplicated on the member', (done) ->
      @sinon.stub paymentUtils, 'createCustomer', (t, m, cb) -> cb(null, id: 'stripe_customer_id')
      @member.stripeCards.set 0, '5678'
      @member.save (err) =>
        return done(err) if err
        @api
          .post '/members/' + @member._id.toString() + '/stripe-customer'
          .json()
          .send
            stripeToken: "tok"
            cardLast4: "5678"
          .expectStatus 200
          .end (err, res, body) =>
            return done(err) if err
            Member.findOne _id: @member._id, (err, member) =>
              return done(err) if err
              expect(member.stripeId).to.be.equal 'stripe_customer_id'
              expect(member.stripeCards).to.be.like ['5678']
              done()
