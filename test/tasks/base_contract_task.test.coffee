sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

contracts = require('../../ethic/models/contract.js').contracts
queues = require '../../ethic/queues.js'
tasks = require '../../ethic/tasks'
BaseTask = tasks.BaseTask
BaseContractTask = tasks.BaseContractTask


describe 'BaseContractTask', ->

  describe 'delay', ->
    it 'should make sure contractType exists', ->
      @sinon.stub BaseTask, 'delay'
      BaseContractTask.delay
        contractType: 'ca'
      expect(BaseTask.delay).to.have.been.calledWithMatch contractType: 'ca'

    it 'should raise if contractType does not exsit', ->
      @sinon.stub BaseTask, 'delay'
      expect(-> BaseContractTask.delay contractType: 'fr').to.throw Error
      expect(BaseTask.delay).to.have.not.been.called

    it 'should raise if contractType is undefined', ->
      @sinon.stub BaseTask, 'delay'
      expect(BaseContractTask.delay).to.throw Error
      expect(BaseTask.delay).to.have.not.been.called

  describe 'ensureContract', ->
    it 'should return contract if exists', ->
      expect(BaseContractTask.ensureContract contractType: 'ca').to.be.equal contracts.ca

    it 'should raise if not', ->
      expect(-> BaseContractTask.ensureContract contractType: 'or').to.throw Error

    it 'should raise if not specified in data', ->
      expect(BaseContractTask.ensureContract).to.throw Error

  describe 'run', ->
    it 'should set the contract on the task', ->
      @sinon.stub BaseTask::, 'run'
      cb = ->
      t = new BaseContractTask()
      t.run contractType: 'ca'
      expect(t.contract).to.be.equal contracts.ca
      expect(BaseTask::run).to.have.been.calledWithMatch contractType: 'ca'
