var VERSION = '0.0.1';

module.exports = {
  version: VERSION,
  home: function (req, res, next) {
    res.send({
      "name": "ethic",
      "version": VERSION
    });
    return next();
  }
};
