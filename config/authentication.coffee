crypto = require('crypto')

module.exports = (compound) ->

  getUser = (id, callback) ->
    return callback() if not id
    compound.models.User.findOne {_id: id}, callback

  return {
    config: {
      consumerKey: 'oTGWRU2D0wriEUBduYBZHg'
      consumerSecret: 'cWRG1NKSGmdW6EizaCFMfaK5ImIxST4F09nRdWERst0'
      callback: '/auth/twitter'
    }
    authenticate: (req, res, next) ->
      # set fixed guest name
      if not req.cookies.n 
        res.cookie 'n', 'Guest ' + Math.ceil(Math.random()*1000000 +50000) 

      # return if not authenticated
      if not req.cookies.i
        return next() 

      # authenticate
      getUser req.cookies.i, (err, user) ->
        if err 
          console.error 'authentication error', err
          return next()
        else
          console.log 'user authenticated', user.screen_name
          req.user = req.locals.user = user if user
          next()

    authenticateSocket: (socket, callback) ->
      for cookie in socket.handshake.headers.cookie.split(';')
        id = cookie.split('=')[1].trim() if cookie.split('=')[0].trim() is 'i'
        guest_name = decodeURI(cookie.split('=')[1].trim()) if cookie.split('=')[0].trim() is 'n'

      if id?
        return getUser id, (err, user) ->
          socket.user = user if user
          callback err, socket

      else
        socket.user = {
          screen_name: guest_name || 'Gusta'
          avatar: 'http://www.gravatar.com/avatar/' + crypto.createHash('md5').update(guest_name).digest('hex') + '?d=monsterid&s=48'
        }
        callback null, socket

        
        
  }
