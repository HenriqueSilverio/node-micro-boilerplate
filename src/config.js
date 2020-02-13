const env = require('require-env')

module.exports = {
  MONGO_URI: env.require('MONGO_URI')
}
