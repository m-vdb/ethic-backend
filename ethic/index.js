// mongodb needs to be configured before
require('./mongo');

var restify = require('restify'),
    passport = require('passport'),
    web3 = require('web3'),
    config = require('config'),
    CookieParser = require('restify-cookies');

var web3Admin = require('./utils/web3-admin.js'),
    routes = require('./routes.js'),
    auth = require('./auth'),
    payment = require('./payment'),
    restifyUtils = require('./utils/restify'),
    restifyMongooseUtils = require('./utils/restify-mongoose');

web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));
web3Admin();  // required to use admin calls
var server = restify.createServer({
  name: 'ethic-backend',
  version: config.get('version')
});

// auth
var jwtStrategy = auth.jwt();
server.use(CookieParser.parse);
server.use(passport.initialize());

// common handlers
server.use(restify.fullResponse())
server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());
restify.CORS.ALLOW_HEADERS.push('cache-control');
restify.CORS.ALLOW_HEADERS.push('x-requested-with');
server.use(restify.CORS(config.get('corsOptions')));

// utils
server.use(restifyMongooseUtils());
server.use(restifyUtils());

// debugging
server.pre(function (request, response, next) {
  console.log(request.method, request.url);
  next();
});

// routes
server.get('/', jwtStrategy, routes.home);
server.post('/authenticate', auth.routes.authenticate);
server.get('/member', jwtStrategy, routes.member);
server.post('/members', jwtStrategy, routes.createMember);
server.get('/members/:id', jwtStrategy, routes.member);
server.post('/members/:id/accept', jwtStrategy, routes.acceptMember);
server.post('/members/:id/deny', jwtStrategy, routes.denyMember);
server.get('/members/:id/policies', jwtStrategy, routes.memberPolicies);
server.post('/members/:id/policies', jwtStrategy, routes.createMemberPolicy);
server.post('/members/:id/policies/:policyId/proof', jwtStrategy, routes.updatePolicyProofOfInsurance);
server.get('/members/:id/claims', jwtStrategy, routes.memberClaims);
server.post('/members/:id/claims', jwtStrategy, routes.createMemberClaims);

// payment routes
server.post('/members/:id/stripe-customer', jwtStrategy, payment.routes.createStripeCustomer);

module.exports = server;
