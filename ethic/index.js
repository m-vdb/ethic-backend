var restify = require('restify'),
    routes = require('./routes.js'),
    auth = require('./auth.js')
    passport = require('passport');

var server = restify.createServer({
  name: 'ethic-backend',
  version: routes.version
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
server.post('/users', routes.createUser);
server.get('/users/:address', routes.user);
server.post('/users/:address/accept', routes.acceptUser);
server.post('/users/:address/deny', routes.denyUser);
server.get('/users/:address/policies', routes.userPolicies);
server.post('/users/:address/policies', routes.createUserPolicy);
server.get('/users/:address/claims', routes.userClaims);
server.post('/users/:address/claims', routes.createUserClaims);


module.exports = server;
