var restify = require('restify');

module.exports = function () {
  return function(req, res, next) {
    req.getDocumentOr404 = function (Document, params, cb) {
      if (typeof Document.findOne != 'function') {
        // 500
        cb(new restify.errors.InternalServerError('Bad Document type.'));
      }
      Document.findOne(params, function (err, doc) {
        if (err) cb(err);
        else if (!doc) cb(new restify.errors.NotFoundError());
        else cb(null, doc);
      });
    }
    return next();
  };
};
