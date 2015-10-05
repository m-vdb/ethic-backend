sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

_ = require 'underscore'
web3 = require 'web3'
ethUtils = require '../../ethic/utils/eth.js'

describe 'eth', ->
  beforeEach ->
    @sinon = sinon.sandbox.create()
    @clock = @sinon.useFakeTimers()
    @sinon.stub web3, 'eth',
      accounts: ['0x123456678910']
      getTransactionReceipt: @sinon.stub()


  afterEach ->
    @sinon.restore()

  describe 'createAccount', ->

    beforeEach ->
      @sinon.stub web3.personal, "newAccount", -> '0x007'

    it 'should call web3.personal.newAccount', ->
      expect(ethUtils.createAccount 'callback').to.be.equal '0x007'
      expect(web3.personal.newAccount).to.be.have.been.calledWith 'toto', 'callback'

  describe 'extractCallback' , ->

    it 'should return callback function if any', ->
      fn = -> false
      expect(ethUtils.extractCallback [123, (-> true), "221", fn]).to.be.equal fn

    it 'should return _.noop otherwise', ->
      expect(ethUtils.extractCallback [123, (-> true), "221"]).to.be.equal _.noop

  describe 'getOptions', ->
    it 'should return default call options', ->
      expect(ethUtils.getOptions()).to.be.like from: web3.eth.accounts[0]

  describe 'formatOutput', ->
    it 'should do nothing with strings', ->
      expect(ethUtils.formatOutput '0x528136').to.be.equal '0x528136'

    it 'should do nothing with ints', ->
      expect(ethUtils.formatOutput 2134).to.be.equal 2134

    it 'should get obj.c[0] property for objects', ->
      expect(ethUtils.formatOutput {key: 'value', c: [12354]}).to.be.equal 12354

    it 'should format each element of an array according to the ABI config', ->
      abiOutputs = [{name: 'created_at'}, {name: 'id'}]
      obj = [{key: 'value', c: [12354]}, '0x123164521']
      expect(ethUtils.formatOutput obj, abiOutputs).to.be.like
        id: '0x123164521'
        created_at: 12354

  describe 'makeAccessor', ->

    it 'should return a method that formats its output', ->
      contract =
        func: (v) -> [{key: 'value', c: [v]}, '0x123164521']
      abi =
        name: "func"
        outputs: [{name: 'created_at'}, {name: 'id'}]

      fn = ethUtils.makeAccessor contract, abi
      expect(fn 25187681).to.be.like
        id: '0x123164521'
        created_at: 25187681

  describe 'blockUntilTransactionDone', ->
    it 'should try 20 second to get the transaction receipt and stop if cannot get it', ->
      web3.eth.getTransactionReceipt.returns null
      cb = @sinon.spy()
      ethUtils.blockUntilTransactionDone '0xabcdef', cb

      @clock.tick 1000 * 21
      expect(cb).to.have.been.calledWith 'Cannot get transaction receipt.', null
      expect(web3.eth.getTransactionReceipt.callCount).to.be.equal 20

    it 'should call the callback when receipt has been retrieved', ->
      web3.eth.getTransactionReceipt.returns null
      cb = @sinon.spy()
      ethUtils.blockUntilTransactionDone '0xabcdef', cb

      @clock.tick 1000 * 11
      expect(web3.eth.getTransactionReceipt.callCount).to.be.equal 11

      web3.eth.getTransactionReceipt.returns
        hash: '0xabcdef'
        key: 'value'
      @clock.tick 1000
      expect(cb).to.have.been.calledWithMatch null,
        hash: '0xabcdef'
        key: 'value'
      expect(web3.eth.getTransactionReceipt.callCount).to.be.equal 12

  describe 'makeMethod', ->
    it 'should provide callback that exits on error', ->
      contract =
        func: @sinon.stub().yields('error', '0x1337')
      abi =
        name: "func"

      fn = ethUtils.makeMethod contract, abi
      cb = @sinon.spy()
      fn('some arg', cb)
      expect(contract.func).to.have.been.calledWithMatch 'some arg',
        from: '0x123456678910'
        gas: 1000000
      expect(cb).to.have.been.calledWith 'error'

    it 'should provide callback that gives error if no tx receipt', ->
      @sinon.stub(ethUtils, 'blockUntilTransactionDone').yields 'no receipt', null
      contract =
        func: @sinon.stub().yields(null, '0x1337')
      abi =
        name: "func"

      fn = ethUtils.makeMethod contract, abi
      cb = @sinon.spy()
      fn('some arg', cb)
      expect(ethUtils.blockUntilTransactionDone).to.have.been.calledWithMatch '0x1337'
      expect(cb).to.have.been.calledWith 'no receipt'

    it 'should provide callback that gives error if ran out of gas', ->
      @sinon.stub(ethUtils, 'blockUntilTransactionDone').yields null, cumulativeGasUsed: 1000000000
      contract =
        func: @sinon.stub().yields(null, '0x1337')
      abi =
        name: "func"

      fn = ethUtils.makeMethod contract, abi
      cb = @sinon.spy()
      fn('some arg', cb)
      expect(ethUtils.blockUntilTransactionDone).to.have.been.calledWithMatch '0x1337'
      expect(cb).to.have.been.calledWith 'Transaction ran out of gas.'

    it 'should provide callback that gives success otherwise', ->
      @sinon.stub(ethUtils, 'blockUntilTransactionDone').yields null, cumulativeGasUsed: 1337
      contract =
        func: @sinon.stub().yields(null, '0x1337')
      abi =
        name: "func"

      fn = ethUtils.makeMethod contract, abi
      cb = @sinon.spy()
      fn('some arg', cb)
      expect(ethUtils.blockUntilTransactionDone).to.have.been.calledWithMatch '0x1337'
      expect(cb).to.have.been.calledWith null

    it 'should use api\'s gas if any', ->
      @sinon.stub(ethUtils, 'blockUntilTransactionDone').yields null, cumulativeGasUsed: 1337
      contract =
        func: @sinon.stub().yields(null, '0x1337')
      abi =
        name: "func"
        gas: 1337

      fn = ethUtils.makeMethod contract, abi
      cb = @sinon.spy()
      fn('some arg', cb)
      expect(ethUtils.blockUntilTransactionDone).to.have.been.calledWithMatch '0x1337'
      expect(cb).to.have.been.calledWith 'Transaction ran out of gas.'
