'use strict';
var queues = require('../queues.js');


class BaseTask {
  constructor() {
    this.taskName = this.constructor.name;
  }

  static delay (data, queue, cb) {
    if (typeof queue == 'function') {
      cb = queue;
      queue = null;
    }

    queue = queue || 'main';
    var job = queues[queue]
      .create(this.name, data)
      .save(cb);
  }

  run (data, cb) {
    console.log('Processing task:', this.taskName);
    return this.process(data, cb);
  }

  process (data, cb) {  // to override in sub classes
    cb();
  }
}


module.exports = BaseTask;
