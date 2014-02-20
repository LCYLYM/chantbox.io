rooms = {}

io = do ->
  init = false
  return (io) ->
    return if init; init = true
    console.log "Init socket.io event on RoomsController"
    sockets = io.sockets

    sockets.on 'connection', (socket) ->
      console.log "#{socket.id} connected"
      socket.on 'room:join', (room, as) ->
        socket.join room
        socket.room = room
        socket.as = as
        console.log as, socket.as
        console.log "#{socket.as} joins #{socket.room}"
        user = {
          name: if socket.as.indexOf('@') > -1 then socket.as.split('@')[0] else socket.as
          hash: require('crypto').createHash('md5').update(socket.as).digest('hex')
          as: socket.as
          joined: new Date
        }
        rooms[room] = {} if not rooms[room]
        rooms[room][user.as] = user
        sockets.in(room).emit 'room:join', {room: socket.room, user: user}, rooms[socket.room]

      socket.on 'disconnect', ->
        console.log "#{socket.as} leaves #{socket.room}"
        delete rooms[socket.room][socket.as]
        sockets.in(socket.room).emit 'room:leave', {as: socket.as}, rooms[socket.room]
        socket.leave socket.room
        

module.exports = class RoomsController

  constructor: (init) ->
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