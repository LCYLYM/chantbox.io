module.exports = (compound, Room) ->
  
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
      
  Room.prototype.addUser = (screen_name, callback) ->
    console.log "Room.prototype.addUser, #{@name}, #{screen_name}"
    if screen_name not in @users
      @users.push screen_name 
      @save (err) =>
        callback err, @users if callback
    else
      callback null, @users if callback

  Room.prototype.removeUser = (screen_name, callback) ->
    console.log "Room.prototype.removeUser, #{@name}, #{screen_name}"
    index = @users.indexOf screen_name
    if index > -1
      @users.splice index, 1 
      @save (err) => 
        callback err, @users if callback
    else
      callback null, @users if callback

  Room.prototype.kill = (callback) ->
    return callback 'cannot remove a room with users' if @users.length > 0
    return callback 'cannot remove a fixed room' if @settings.fixed
    @remove (err) ->
      callback err if callback
