# before 'protect from forgery', ->
  # protectFromForgery '7fb8d0fc0fec31e1c2f1da1a7e9393d9fddde428'

module.exports = class ApplicationController 

  constructor: (init) ->
    init.before (c) =>
      @c = c
      c.next() 

  index: =>
    @c.render {page: "homepage"}

  room: =>
    @c.Room.getOrCreate @c.req.params.room, @c.req.query, @c.req.user, (err, room) =>
      return @error(err) if err
      @c.render {
        title: @c.app.locals.title + " | " + room.name
        room: room
        page: "room"
      }

  error: (m) =>
    console.error "Error: #{m}"
    @c.send 500, m
