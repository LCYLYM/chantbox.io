# before 'protect from forgery', ->
  # protectFromForgery '7fb8d0fc0fec31e1c2f1da1a7e9393d9fddde428'

module.exports = class ApplicationController 

  constructor: (init) ->
    init.before (c) =>
      @c = c
      c.next()

  index: =>
    @c.render()