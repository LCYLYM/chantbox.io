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

  Room.get = (name, callback) ->
    Room.findOne {name: name}, callback
      
  Room.prototype.addUser = (user, callback) ->
    console.log "Room.prototype.addUser, #{@name}, #{user.screen_name}"
    @users = {} if not @users
    @users[user.screen_name] = user
    @markModified 'users'
    @save (err) =>
      callback err, @users if callback

  Room.prototype.removeUser = (user, callback) ->
    console.log "Room.prototype.removeUser, #{@name}, #{user.screen_name}"
    if @users?[user.screen_name]
      delete @users[user.screen_name]
      @markModified 'users'
      @save (err) => 
        callback err, @users if callback
    else
      callback null, @users if callback

  Room.prototype.kill = (callback=->) ->
    return callback 'cannot remove a room with users' if Object.keys(@users||{}).length > 0
    return callback 'cannot remove a fixed room' if @settings.fixed
    @remove (err) =>
      console.log "Room.prototype.kill #{@name}"
      callback err
      
