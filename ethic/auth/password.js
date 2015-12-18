'use strict';
var config = require('config'),
    crypto = require('crypto');


/**
 * Hash a password. Used before saving it in database.
 */
function hashPassword (password) {
  return crypto
    .createHmac("sha256", config.get('authSecret'))
    .update(password)
    .digest('hex');
}
/**
 * Check password against a hash.
 */
function checkPassword (hash, password) {
  return hashPassword(password) == hash;
}


module.exports.hashPassword = hashPassword;
module.exports.checkPassword = checkPassword;
