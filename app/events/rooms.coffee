module.exports = (sockets, socket, Room) -> 

  users = (room) ->
    list = {}
    sockets.clients(room).map (client) -> list[client.user.screen_name] = client.user
    return list

  message = (type, content, user) ->
    source = type + (if user? then ", #{user.screen_name}" else '') + ", ##{socket.room}" 
    console.log "Room.emit.message (#{source}): #{content}"
    sockets.in(socket.room).emit 'message', {content: content, type: type, user: user}    

  socket.on 'join', (room, fixed) ->
    console.log "Room.on.join: #{socket.user.screen_name} joins #{room}"
    socket.join room, ->
      socket.room = room
      sockets.in(room).emit 'join', users(room)
      message 'system', "#{socket.user.screen_name} joined ##{socket.room}"

  socket.on 'disconnect', ->
    return if not socket.room
    console.log "Room.on.disconnect: #{socket.user.screen_name} leaves #{socket.room}"
    socket.leave socket.room, ->
      sockets.in(socket.room).emit 'leave', users(socket.room)
      message 'system', "#{socket.user.screen_name} left #{socket.room}"
      # if Object.keys(users(socket.room)).length == 0
      # Room.get socket.room, (err, room) -> room.kill() if room

  socket.on 'message', (content) ->
    # console.log "message from #{socket.user.screen_name} on #{socket.room}: #{content}"
    message 'user', content, socket.user

  # init
  do (socket) ->
    socket.emit 'ready', socket.user
 