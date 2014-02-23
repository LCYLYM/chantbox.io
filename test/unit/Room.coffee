describe 'Model: Room', ->

  Room = null
  User = null
  
  before ->
    Room = compound.models.Room
    User = compound.models.User

  it 'should empty Rooms', (done) ->
    Room.collection.remove (err) ->
      expect(err).to.equal null
      Room.find (err, rooms) ->
        rooms.length.should.equal 0
        done()

  it 'should create an anonymous room for all users', (done) -> 
    Room.getOrCreate 'temp1', {}, null, (err, room) ->
      room.name.should.equal 'temp1'
      room.settings.anonymous.should.equal true
      done()

  it 'shouldnt create a fixed room only for an anonymous user', (done) ->
    Room.getOrCreate 'temp1', {create: "1"}, {}, (err, room) ->
      expect(err).to.equal 'anonymous users cannot create persistent rooms'
      expect(room).to.equal null
      done()

  it 'should create a fixed room for a registered user', (done) ->
    user = new User({screen_name: 'test-user'})
    Room.getOrCreate 'fixed1', {create: "1"}, user, (err, room, created) ->
      expect(err).to.equal null
      room.name.should.equal 'fixed1'
      room.createdAt.should.be.instanceOf Date
      room.settings.anonymous.should.equal false
      room.creator.should.equal user._id.toString()
      done()