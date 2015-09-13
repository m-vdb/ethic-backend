var mongoose = require('mongoose');

var apiUserSchema = new mongoose.Schema({
  username: {type: String, index: {unique: true}},
  password: String
}, {
  collection: 'api_users'
});


module.exports = mongoose.model('ApiUser', apiUserSchema);
