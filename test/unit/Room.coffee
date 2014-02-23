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
    Room.getOrCreate 'temp1', {}, null, (err, room, created) ->
      created.should.equal true
      room.name.should.equal 'temp1'
      room.settings.fixed.should.equal false
      expect(room.creator).to.equal undefined
      done()

  it 'shouldnt create a fixed room only for an anonymous user', (done) ->
    Room.getOrCreate 'temp2', {fixed: "1"}, null, (err, room) ->
      expect(err).to.equal 'anonymous users cannot create persistent rooms'
      expect(room).to.equal null
      done()

  it 'should create a temp room for a user', (done) ->
    user = new User({screen_name: 'test-user'})
    Room.getOrCreate 'temp3', {}, user, (err, room, created) ->
      room.settings.fixed.should.equal false
      room.creator.should.equal user._id
      created.should.equal true
      done()

  it 'should create a fixed room for a registered user', (done) ->
    user = new User({screen_name: 'test-user'})
    Room.getOrCreate 'fixed1', {fixed: "1"}, user, (err, room, created) ->
      expect(err).to.equal null
      room.name.should.equal 'fixed1'
      room.createdAt.should.be.instanceOf Date
      room.settings.fixed.should.equal true
      room.creator.should.equal user._id
      created.should.equal true
      done()

  it 'should not destory a fixed room', (done) ->
    Room.getOrCreate 'fixed', {fixed: true}, new User({name: 'some_user'}), (err, room, created) ->
      room.kill (err) ->
        expect(err).to.equal 'cannot remove a fixed room'
        done() 

  it 'should get a room by its name', (done) ->
    Room.get 'temp3', (err, room) ->
      expect(err).to.equal null
      room.name.should.equal 'temp3'
      done()