ROOMS = {}

module.exports = (sockets, socket) ->

  message = (type, content, user={}) ->
    console.log 'message', {screen_name: user.screen_name, content: content, type: type}
    sockets.in(socket.room).emit 'message', {content: content, type: type, user: user} 

  socket.on 'join', (room, notify) ->
    console.log "#{socket.user.screen_name} joins #{room}"
    socket.join room
    socket.room = room
    
    if not ROOMS[room]?[socket.user.screen_name]? # don't double rejoin (different windows)  
      ROOMS[room] = {} if not ROOMS[room]
      ROOMS[room][socket.user.screen_name] = socket.user
      sockets.in(room).emit 'join', ROOMS[socket.room]
      message 'system', "#{socket.user.screen_name} joined ##{socket.room}" if notify 

  socket.on 'disconnect', ->
    return if not socket.room
    console.log "#{socket.user.screen_name} leaves #{socket.room}"
    delete ROOMS[socket.room][socket.user.screen_name]
    sockets.in(socket.room).emit 'leave', socket.user.screen_name
    socket.leave socket.room
    message 'system', "#{socket.user.screen_name} left #{socket.room}"

  socket.on 'message', (content) ->
    console.log "message from #{socket.user.screen_name} on #{socket.room}: #{content}"
    message 'user', content, socket.user