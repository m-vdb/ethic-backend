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


module.exports = server;
