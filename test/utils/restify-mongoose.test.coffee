chai = require 'chai'
expect = chai.expect

restify = require 'restify'
restifyMongoose = require('../../ethic/utils/restify-mongoose.js')()
ApiUser = require '../../ethic/models/api_user.js'

describe 'restify-mongoose-utils', ->
  beforeEach ->
    @req = {}
    @next = @sinon.spy()
    @cb = @sinon.spy()

  describe 'getDocumentOr404', ->

    it 'should return 500 if Document is not mongoose object', ->
      restifyMongoose(@req, @res, @next)
      expect(@next).to.have.been.calledWith()
      @req.getDocumentOr404 {}, key: 'value', @cb
      expect(@cb).to.have.been.calledWithMatch new restify.errors.InternalServerError('Bad Document type.')

    it 'should return 404 if Document is not found', ->
      restifyMongoose(@req, @res, @next)
      expect(@next).to.have.been.calledWith()
      @req.getDocumentOr404(ApiUser, username: 'yup', @cb).then =>
        expect(@cb).to.have.been.calledWithMatch new restify.errors.NotFoundError()

    it 'should return error if findOne returns error', ->
      restifyMongoose(@req, @res, @next)
      expect(@next).to.have.been.calledWith()
      @sinon.stub(ApiUser, 'findOne').yields 'internal mongo error', null
      @req.getDocumentOr404 ApiUser, username: 'yup', @cb
      expect(@cb).to.have.been.calledWithMatch 'internal mongo error'

    it 'should return the document when found', ->
      restifyMongoose(@req, @res, @next)
      expect(@next).to.have.been.calledWith()
      user = new ApiUser
        username: 'john'
        password: 'doe'
      user.save (err) =>
        throw err if err

        @req.getDocumentOr404(ApiUser, username: 'john', @cb).then =>
          expect(@cb).to.have.been.calledWithMatch null,
            username: 'john'
            password: 'doe'
