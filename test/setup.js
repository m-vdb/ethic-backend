var chai = require("chai");
var sinonChai = require("sinon-chai");
var chaiFuzzy = require("chai-fuzzy");
chai.use(sinonChai);
chai.use(chaiFuzzy);

// set the NODE_ENV to 'test' and load the config
process.env.NODE_ENV = "test";
var config = require('config');

var web3Admin = require('../ethic/utils/web3-admin.js');
web3Admin();
