var restify = require('restify'),
    passport = require('passport'),
    BasicStrategy = require('passport-http').BasicStrategy;

passport.use(new BasicStrategy(function (username, password, done) {
  // TODO: check credentials against database
  if (username == 'toto') {
    return done(null, {username: username});
  }

  return done(null, false, {message: "Incorrect credentials."});
}));

module.exports = function () {
  return passport.authenticate('basic', {session: false});
};
