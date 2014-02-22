module.exports = (compound) ->

  crypto    = require 'crypto'
  express   = require 'express'
  io        = require('socket.io').listen compound.server, {log: false}
  app       = compound.app

  require('./mongoose').init(compound)
  twitter = require('./twitter')(compound)

  app.configure ->
    app.enable 'coffee'
    app.set 'cssEngine', 'stylus'
    compound.loadConfigs __dirname

    # make sure you run `npm install railway-routes browserify`
    # app.enable 'clientside'
    app.use express.static(app.root + '/public', maxAge: 86400000)
    app.use express.urlencoded()
    app.use express.json()
    app.use express.cookieParser 'mnsjsu477383hfhbvgata5151ref'
    # app.use express.session secret: 'mnsjsu477383hfhbvgata5151ref'
    app.use express.methodOverride()
    app.use twitter.authenticate

    app.locals.title = 'chantbox.io'
    app.locals.assets_timestamp = +(new Date)
    app.use app.router

  io.sockets.on 'connection', (socket) ->
    twitter.authenticateSocket socket, (err, socket) ->
      require('../app/events/rooms')(io.sockets, socket) 

