describe 'Model: Line', ->

  Room = null
  User = null
  Line = null

  before ->
    Room = compound.models.Room
    User = compound.models.User
    Line = compound.models.Line

  it 'should empty data', (done) ->
    Room.collection.remove -> 
      Line.collection.remove -> 
        User.collection.remove done

  it 'should create a line for a fixed room', (done) ->
    Room.getOrCreate 'line1', {fixed: "1"}, new User({screen_name: "@sagish"}), (err, room) ->
      room.addLine {type: 'user', content: 'Line test', user: new User({screen_name: '@testi'})}, (err, line) ->
        line.createdAt.should.be.instanceOf Date
        line.room.toString().should.equal room._id.toString()
        line.type.should.equal 'user'
        line.user.screen_name.should.equal '@testi'
        done()
  