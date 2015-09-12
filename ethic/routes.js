module.exports = {
  home: function (req, res, next) {
    res.send({
      "name": "ethic"
    });
    return next();
  }
};
