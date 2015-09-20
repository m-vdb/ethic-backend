var restify = require('restify'),
    validator = require('restify-validator'),
    passport = require('passport'),
    mongoose = require('mongoose');

var web3Admin = require('./utils/web3-admin.js'),
    settings = require('./settings.js'),
    routes = require('./routes.js'),
    auth = require('./auth.js'),
    restifyMongooseUtils = require('./utils/restify-mongoose-utils');

web3Admin();  // required to use admin calls
var server = restify.createServer({
  name: 'ethic-backend',
  version: settings.version
});

// auth
server.use(passport.initialize());
server.use(auth());

// common handlers
server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());

// utils
server.use(validator);
server.use(restifyMongooseUtils());

// debugging
server.pre(function (request, response, next) {
  console.log(request.method, request.url);
  next();
});

// routes
server.get('/', routes.home);
server.post('/members', routes.createMember);
server.get('/members/:address', routes.member);
server.post('/members/:id/accept', routes.acceptMember);
server.post('/members/:id/deny', routes.denyMember);
server.get('/members/:address/policies', routes.memberPolicies);
server.post('/members/:address/policies', routes.createMemberPolicy);
server.get('/members/:address/claims', routes.memberClaims);
server.post('/members/:address/claims', routes.createMemberClaims);


// mongodb
mongoose.connect(settings.mongoUri, settings.mongoOptions);

module.exports = server;
