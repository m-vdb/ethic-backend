var chai = require("chai");
var sinonChai = require("sinon-chai");
var chaiFuzzy = require("chai-fuzzy");
chai.use(sinonChai);
chai.use(chaiFuzzy);

var web3Admin = require('../ethic/utils/web3-admin.js');
web3Admin();
