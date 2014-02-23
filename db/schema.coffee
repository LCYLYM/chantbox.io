module.exports = (mongoose, compound) ->

  User = mongoose.model 'User', mongoose.Schema {
    screen_name: {type: String, index: {unique: true, sparse: true}}
    avatar: String
    createdAt: {type: Date, default: new Date}
  }
  User.modelName = 'User'
  compound.models.User = User

  Room = mongoose.model 'Room', mongoose.Schema {
    name: {type: String, index: {unique: true}}
    creator: {type: mongoose.Schema.ObjectId, ref: 'User'}
    settings: {type: {
      fixed: Boolean
    }}
    moderators: [{}]
    createdAt: {type: Date}
  }
  Room.modelName = 'Room'
  compound.models.Room = Room 

  Line = mongoose.model 'Line', mongoose.Schema {
    type: {type: String, index: true}
    user: {type: {}}
    content: {type: String}
    extra: {type: {}}
    room: {type: mongoose.Schema.ObjectId, ref: 'Room', index: true}
    createdAt: {type: Date, default: new Date, index: true}
  }
  Line.modelName = 'Line'
  compound.models.Line = Line
