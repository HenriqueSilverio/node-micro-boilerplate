const env = require('require-env')

module.exports = {
  serviceName: env.require('SERVICE_NAME')
}
