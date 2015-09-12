var restify = require('restify');
var routes = require('./routes.js');

var server = restify.createServer({
  name: 'ethic-backend',
  version: routes.version
});
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
server.get('/users/:address', routes.user);
server.get('/users/:address/policies', routes.userPolicies);
server.post('/users/:address/policies', routes.createUserPolicy);
server.get('/users/:address/claims', routes.userClaims);
server.post('/users/:address/claims', routes.createUserClaims);


module.exports = server;
