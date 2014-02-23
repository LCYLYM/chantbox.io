describe 'Init', ->
  before ->
    process.env.NODE_ENV.should.equal 'test'
    process.exit() if process.env.NODE_ENV isnt "test"

  global.expect = require 'expect.js'
  global.should = require 'should'
  global.compound = require('compound').createServer()

    