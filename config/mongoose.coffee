exports.init = (compound) ->
  conf = require('./database')[compound.app.set('env')]
  mongoose = require('mongoose')
  mongoose.connect(conf.url)
  require(compound.root + '/db/schema')(mongoose, compound)
