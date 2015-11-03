var EdmundsClient = require('node-edmunds-api'),
    settings = require('../settings.js');

var edmundsClient = new EdmundsClient({
  apiKey: settings.edmunds.apiKey
});

module.exports = {
  decodeVin: function (vin, cb) {
    edmundsClient.decodeVin({vin: vin}, function (err, resp) {
      if (err) return cb(err);

      cb(null, {
        make: resp.make.name,
        make_id: resp.make.niceName,
        model: resp.model.name,
        model_id: resp.model.niceName,
        year: resp.years[0].year,
        size: resp.categories.vehicleSize,
        style: resp.categories.vehicleStyle
      });
    });
  }
};
