module.exports = (sockets, socket, Room) -> 

  users = (room) ->
    list = {}
    sockets.clients(room).map (client) -> list[client.user.screen_name] = client.user
    return list

  message = (type, content, user, log=true) ->
    if socket.room
      data = {content: content, type: type, user: user}
      source = type + (if user? then ", #{user.screen_name}" else '') + ", ##{socket.room.name}" 
      console.log "Room.emit.message (#{source}): #{content}"
      sockets.in(socket.room.name).emit 'message', data
      socket.room.addLine data if log # if room.settings.fixed

  socket.on 'join', (room, fixed, getHistory) ->
    console.log "Room.on.join: #{socket.user.screen_name} joins #{room}"
    socket.user.status = 'Joined'
    Room.getOrCreate room, {fixed: fixed}, (if socket.user._id then socket.user else null), (err, room) ->
      message 'system', err if err
      socket.join room.name, ->
        socket.room = room
        sockets.in(room.name).emit 'join', users(room.name)
        socket.emit 'room', room, socket.user
        if getHistory
          room.getLines 10, 0, (err, lines) =>
            message l.type, l.content, l.user, false for l in lines
            message 'system', "#{socket.user.screen_name} joined ##{socket.room.name}"
        else
          message 'system', "#{socket.user.screen_name} joined ##{socket.room.name}"

  socket.on 'disconnect', ->
    return if not socket.room
    console.log "Room.on.disconnect: #{socket.user.screen_name} leaves #{socket.room.name}"
    socket.leave socket.room.name, ->
      sockets.in(socket.room.name).emit 'leave', users(socket.room.name)
      message 'system', "#{socket.user.screen_name} left #{socket.room.name}"
      socket.room.kill() if Object.keys(users(socket.room.name)).length == 0

  socket.on 'message', (content) ->
    message 'user', content, socket.user

  socket.on 'status', (status) ->
    if socket.room
      console.log "status: #{socket.user.screen_name} in ##{socket.room.name} is #{status}"
      socket.user.status = status
      socket.in(socket.room.name).emit 'status', socket.user.screen_name, status

  # init
  do (socket) ->
    socket.emit 'ready'
 