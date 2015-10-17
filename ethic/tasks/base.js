var queues = require('../queues.js');


function BaseTask (data) {
  this.taskName = this.constructor.name;
}

// class methods

BaseTask.delay = function (data, queue, cb) {
  if (typeof queue == 'function') {
    cb = queue;
    queue = null;
  }

  queue = queue || 'main';
  var job = queues[queue]
    .create(this.name, data)
    .save(function (err) {
      if (!err) console.log("Task send:", job.id);
      cb(err);
    });
}

// instance methods

BaseTask.prototype.run = function (data, cb) {
  console.log('Processing task:', this.taskName);
  return this.process(data, cb);
};


// to override in sub classes
BaseTask.prototype.process = function (data, cb) {
  console.log('BaseTask yeah');
  cb();
};

module.exports = BaseTask
