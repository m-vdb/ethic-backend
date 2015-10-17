var queues = require('../queues.js');


function BaseTask () {
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
    .save(cb);
}

// instance methods

BaseTask.prototype.run = function (data, cb) {
  console.log('Processing task:', this.taskName);
  return this.process(data, cb);
};


// to override in sub classes
BaseTask.prototype.process = function (data, cb) {
  cb();
};

module.exports = BaseTask
