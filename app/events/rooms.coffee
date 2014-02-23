module.exports = (sockets, socket, Room) -> 

  message = (type, content, user) ->
    source = type + (if user? then ", #{user.screen_name}" else '') + ", ##{socket.room.name}" 
    console.log "Room.emit.message (#{source}): #{content}"
    sockets.in(socket.room.name).emit 'message', {content: content, type: type, user: user}    

  socket.on 'join', (roomName, fixed) ->
    Room.get roomName, (err, room) ->
      console.log "Room.on.join: #{socket.user.screen_name} joins #{room.name}"
      socket.join room.name
      socket.room = room
      room.addUser socket.user, (err, users) ->
        sockets.in(room.name).emit 'join', users
        message 'system', "#{socket.user.screen_name} joined ##{socket.room.name}"

  socket.on 'disconnect', ->
    return if not socket.room
    console.log "Room.on.disconnect: #{socket.user.screen_name} leaves #{socket.room.name}"
    sockets.in(socket.room.name).emit 'leave', socket.user.screen_name
    socket.leave socket.room.name
    socket.room.removeUser socket.user, (err, users) -> 
      message 'system', "#{socket.user.screen_name} left #{socket.room.name}"
      # socket.room.kill() if sockets.clients(socket.room.name).length == 0

  socket.on 'message', (content) ->
    # console.log "message from #{socket.user.screen_name} on #{socket.room}: #{content}"
    message 'user', content, socket.user

  # init
  do (socket) ->
    socket.emit 'ready'
 