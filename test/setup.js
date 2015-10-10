var chai = require("chai");
var sinonChai = require("sinon-chai");
var chaiFuzzy = require("chai-fuzzy");
chai.use(sinonChai);
chai.use(chaiFuzzy);

var web3Admin = require('../ethic/utils/web3-admin.js');
var settings = require('../ethic/settings.js');
web3Admin();
settings.mongoUri = 'mongodb://localhost/ethic-test';
