require('dotenv').load();
var server = require('./ethic');

server.listen(1234, function () {
  console.log('%s listening at %s', server.name, server.url);
});
