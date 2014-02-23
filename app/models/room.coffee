module.exports = (compound, Room) ->

  Room = compound.models.Room
  Line = compound.models.Line
  
  Room.getOrCreate = (name, params, user, callback) ->
    fixed = params.fixed
    Room.findOne({name: name}).populate('creator').exec (err, room) -> 
      # return an existing room
      return callback err, room, false if (err or room)

      # create a new room
      if not room
        return callback('anonymous users cannot create persistent rooms', null) if fixed and not user
        settings = {fixed: false} if not fixed 
        settings = {fixed: true} if fixed and user
        Room.create {name: name, settings: settings, creator: user?._id, createdAt: new Date}, (err, room) ->
          callback err, room, true

  Room.get = (name, callback) ->
    Room.findOne {name: name}, callback
      
  Room.prototype.kill = (callback=->) ->
    return callback 'cannot remove a fixed room' if @settings.fixed
    @remove (err) =>
      console.log "Room.prototype.kill #{@name}"
      callback err

  Room.prototype.addLine = (data, callback=->) ->
    data.createAt = new Date
    data.room = @id
    compound.models.Line.create data, callback

  Room.prototype.getLines = (limit, skip, callback) ->
    Line.find {room: @id, type: {$ne: 'system'}}, null, {limit: limit, skip: skip, sort: '-createdAt'}, (err, lines) ->
      callback err, lines.reverse()