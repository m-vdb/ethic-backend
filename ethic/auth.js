var passport = require('passport'),
    BasicStrategy = require('passport-http').BasicStrategy;

var ApiUser = require('./models/api_user.js');

passport.use(new BasicStrategy(function (username, password, done) {
  ApiUser.findOne({username: username}).select('password').exec(function (err, user) {
    if (err) {
      return done(null, false, err);
    }
    if (!user || user.password !== password) {
      return done(null, false, {message: "Incorrect credentials."});
    }
    return done(null, {username: username});
  });
}));

module.exports = function () {
  return passport.authenticate('basic', {session: false});
};
