chai = require 'chai'
expect = chai.expect

ethUtils = require '../../ethic/utils/eth.js'
Contract = require('../../ethic/models/contract.js').Contract

describe 'Member', ->
  beforeEach ->
    @sinon.stub ethUtils, 'makeAccessor', () -> ((x) -> x)
    @sinon.stub ethUtils, 'makeMethod', () -> ((x) -> x)
    @contract = new Contract
      address: '0x703471a74741cfc62b0fbb16bf1c94fe8b45850a'
      abi: [
        {
          constant: false
          inputs: [{name: "addr", type: "address"}]
          name: "create_member"
          outputs:[]
          type: "function"
        },
        {
          constant: true
          inputs: [{name: "", type: "address"}]
          name: "members"
          outputs: [
            {name: "id", type: "address"},
            {name: "state", type: "uint8"},
            {name: "created_at", type: "uint256"},
            {name: "amount_contributed", type: "uint256"},
            {name: "token_balance", type: "uint256"}
          ]
          type: "function"
        }
      ]

  describe '_attachAbi', ->
    it 'should bind functions properly', ->
      expect(ethUtils.makeMethod).to.have.been.calledWithMatch @contract._contract,
        constant: false
        inputs: [{name: "addr", type: "address"}]
        name: "create_member"
        outputs:[]
        type: "function"
      expect(@contract.create_member).to.be.ok
      expect(@contract.create_member).to.be.a.function

    it 'should bind accessors properly', ->
      expect(ethUtils.makeAccessor).to.have.been.calledWithMatch @contract._contract,
        constant: true
        inputs: [{name: "", type: "address"}]
        name: "members"
        outputs: [
          {name: "id", type: "address"},
          {name: "state", type: "uint8"},
          {name: "created_at", type: "uint256"},
          {name: "amount_contributed", type: "uint256"},
          {name: "token_balance", type: "uint256"}
        ]
        type: "function"
      expect(@contract.members).to.be.ok
      expect(@contract.members).to.be.a.function
