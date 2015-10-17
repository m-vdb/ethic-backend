var _ = require('underscore');
var kue = require('kue');

var queues = require('./ethic/queues.js');
var tasks = require('./ethic/tasks');


_.each(queues, function (queue) {
  _.each(tasks, function (Task, name) {
    queue.process(name, function (job, done) {
      console.log('Task received:', name);
      var task = new Task();
      task.run(job.data, done);
    });
  });
});


kue.app.listen(3000);
