ROOMS = {}

module.exports = (sockets, socket) ->

  message = (type, content, user={}) ->
    console.log 'message', {as: user.as, content: content, type: type}
    sockets.in(socket.room).emit 'message', {content: content, type: type, user: user} 

  socket.on 'room:join', (room, as, notify) ->
    socket.join room
    socket.room = room
    socket.as = as
    console.log "#{socket.as} joins #{socket.room}"
    socket.user = {
      name: if socket.as.indexOf('@') > -1 then socket.as.split('@')[0] else socket.as
      hash: require('crypto').createHash('md5').update(socket.as).digest('hex')
      as: socket.as
      joined: new Date
    }
    
    if not ROOMS[room]?[socket.user.as]? # don't double rejoin (different windows)  
      ROOMS[room] = {} if not ROOMS[room]
      ROOMS[room][socket.user.as] = socket.user
      sockets.in(room).emit 'room:join', ROOMS[socket.room]
      message 'system', "#{socket.as} joined ##{socket.room}" if notify 

  socket.on 'disconnect', ->
    console.log "#{socket.as} leaves #{socket.room}"
    delete ROOMS[socket.room][socket.as]
    sockets.in(socket.room).emit 'room:leave', socket.as
    socket.leave socket.room
    message 'system', "#{socket.as} left #{socket.room}"

  socket.on 'message', (content) ->
    console.log "message from #{socket.as} on #{socket.room}: #{content}"
    message 'user', content, socket.user