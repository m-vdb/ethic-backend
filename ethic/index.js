var restify = require('restify');
var routes = require('./routes.js');

var server = restify.createServer({
  name: 'ethic-backend',
  version: '0.0.1'
});
server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());

// routes
server.get('/', routes.home);


module.exports = server;
