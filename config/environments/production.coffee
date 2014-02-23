express = require 'express'

module.exports = (compound) ->
  app = compound.app
  app.configure 'production', ->
    # app.enable 'quiet'
    app.enable 'merge javascripts'
    app.enable 'merge stylesheets'
    app.enable 'assets timestamps'
    app.use express.errorHandler()
