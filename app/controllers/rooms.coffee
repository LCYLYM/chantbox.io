rooms = {}

io = do ->
  init = false
  return (io) ->
    return if init; init = true
    console.log "Init socket.io event on RoomsController"
    sockets = io.sockets

    sockets.on 'connection', (socket) ->
      console.log "#{socket.id} connected"

      messageRoom = (type, content, user={}) ->
        console.log 'message', {as: user.as, content: content, type: type}
        sockets.in(socket.room).emit 'message', {content: content, type: type, user: user}

      socket.on 'room:join', (room, as) ->
        socket.join room
        socket.room = room
        socket.as = as
        console.log as, socket.as
        console.log "#{socket.as} joins #{socket.room}"
        socket.user = {
          name: if socket.as.indexOf('@') > -1 then socket.as.split('@')[0] else socket.as
          hash: require('crypto').createHash('md5').update(socket.as).digest('hex')
          as: socket.as
          joined: new Date
        }
        if not rooms[room]?[socket.user.as]
          rooms[room] = {} if not rooms[room]
          rooms[room][socket.user.as] = socket.user
          sockets.in(room).emit 'room:join', rooms[socket.room]
          messageRoom 'system', "#{socket.as} joined ##{socket.room}"

      socket.on 'disconnect', ->
        console.log "#{socket.as} leaves #{socket.room}"
        delete rooms[socket.room][socket.as]
        sockets.in(socket.room).emit 'room:leave', socket.as
        socket.leave socket.room
        messageRoom 'system', "#{socket.as} left #{socket.room}"

      socket.on 'message', (content) ->
        console.log "message from #{socket.as} on #{socket.room}: #{content}"
        messageRoom 'user', content, socket.user
        

module.exports = class RoomsController

  constructor: (init) ->
    console.log init.compound

    init.before (c) =>
      @c = c
      io c.compound.io
      @c.next()

  index: =>
    @c.render {
      title: @c.app.locals.title + " | " + @c.req.params.room
      room: @c.req.params.room, 
      as: @c.req.query.as || "Guest #{Math.ceil(Math.random()*100000)+50000}"
      page: "room"
    }