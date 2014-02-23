module.exports = (compound, Room) ->
  
  Room.getOrCreate = (name, params, user, callback) ->
    create = params.create
    Room.findOne {name: name}, (err, room) ->
      return callback(null, new Room({name: name, settings: {anonymous: true}})) if not room and not create
      return callback('anonymous users cannot create persistent rooms', null) if create and not room and not user._id
      if create and not room and user._id
        return Room.create {name: name, settings: {anonymous: false}, creator: user._id, createdAt: new Date}, (err, room) ->
          callback err, room, true
      callback err, room
      # if not room 