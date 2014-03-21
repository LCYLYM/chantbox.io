module.exports = (compound) ->

  require 'newrelic' if compound.app.set('env') is 'production'
    