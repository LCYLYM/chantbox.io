module.exports = class RoomsController

  constructor: (init) ->
    init.before (c) =>
      @c = c
      @c.next()

  index: =>
    @c.render {
      title: @c.app.locals.title + " | " + @c.req.params.room
      room: @c.req.params.room, 
      as: @c.req.query.as || "Guest #{Math.ceil(Math.random()*100000)+50000}"
      page: "room"
    }