express = require 'express'

module.exports = (compound) ->
  app = compound.app
  app.configure 'development', ->
    app.enable 'watch'
    app.enable 'log actions'
    app.enable 'env info'
    app.enable 'assets timestamps'
    app.enable 'force assets compilation'
    app.set 'translationMissing', 'display'
    app.locals.pretty = true
    app.use express.errorHandler dumpExceptions: true, showStack: true
