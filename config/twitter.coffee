crypto = require('crypto')

module.exports = (compound) ->

  getUser = (id, callback) ->
    return callback() if not id
    compound.models.User.findOne {_id: id}, callback

  return {
    config: {
      consumerKey: 'oTGWRU2D0wriEUBduYBZHg'
      consumerSecret: 'cWRG1NKSGmdW6EizaCFMfaK5ImIxST4F09nRdWERst0'
      callback: 'http://dev.chantbox.io:3000/auth/twitter'
    }
    authenticate: (req, res, next) ->
      return next() if not req.cookies.i
      getUser req.cookies.i, (err, user) ->
        if err 
          console.error 'authentication error', err
          return next()
        else
          console.log 'user authenticated', user.screen_name
          req.user = req.locals.user = user if user
          next()

    authenticateSocket: (socket, callback) ->

      socket.user = {
        screen_name: 'Guest ' + Math.ceil(Math.random()*1000000 +50000)
        avatar: 'http://www.gravatar.com/avatar/' + crypto.createHash('md5').update((new Date).getTime().toString()).digest('hex') + '?d=monsterid&s=48'
      }

      return callback(null, socket) if not socket.handshake.headers.cookie

      do ->
        id = null
        socket.handshake.headers.cookie.split(';').forEach (cookie) ->
          id = cookie.split('=')[1].trim() if cookie.split('=')[0].trim() is 'i'
        getUser id, (err, user) ->
          socket.user = user if user
          callback err, socket
  }
