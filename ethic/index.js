var restify = require('restify'),
    passport = require('passport'),
    mongoose = require('mongoose');

var settings = require('./settings.js'),
    routes = require('./routes.js'),
    auth = require('./auth.js');

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
