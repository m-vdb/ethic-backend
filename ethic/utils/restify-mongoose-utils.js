var restify = require('restify');

module.exports = function () {
  return function(req, res, next) {
    req.getDocumentOr404 = function (Document, params, cb) {
      if (typeof Document.findOne != 'function') {
        // 500
        cb(new restify.errors.InternalServerError('Bad Document type.'));
      }
      Document.findOne(params, function (err, document) {
        if (err) cb(err);
        else if (!document) cb(new restify.errors.NotFoundError());
        else cb(null, document);
      });
    }
    return next();
  };
};
