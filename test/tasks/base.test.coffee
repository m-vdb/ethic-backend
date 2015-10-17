sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

queues = require '../../ethic/queues.js'
BaseTask = require('../../ethic/tasks').BaseTask

describe 'BaseTask', ->

  describe 'delay', ->
    it 'should enqueue task in queue', (done) ->
      BaseTask.delay foo: 'bar', ->
        expect(queues.main.testMode.jobs.length).to.be.equal 1
        expect(queues.main.testMode.jobs[0].type).to.equal 'BaseTask'
        expect(queues.main.testMode.jobs[0].data).to.like foo: 'bar'
        done()
    it 'should work with another queue', (done) ->
      BaseTask.delay foo: 'bar', 'dumb', ->
        expect(queues.dumb.testMode.jobs.length).to.be.equal 1
        expect(queues.dumb.testMode.jobs[0].type).to.equal 'BaseTask'
        expect(queues.dumb.testMode.jobs[0].data).to.like foo: 'bar'
        done()

  describe 'constructor', ->
    it 'should initialize taskName', ->
      t = new BaseTask()
      expect(t.taskName).to.be.equal 'BaseTask'

  describe 'run', ->
    it 'should call this.process', ->
      t = new BaseTask()
      t.process = @sinon.spy()
      t.run 'data', 'cb'
      expect(t.process).to.have.been.calledWith 'data', 'cb'

  describe 'process', ->
    it 'should do nothing', ->
      t = new BaseTask()
      t.process {}, ->
        expect(true).to.be.true
