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
    users: [{type: String}]
    moderators: [{}]
    createdAt: {type: Date}
  }
  Room.modelName = 'Room'
  compound.models.Room = Room

  Line = mongoose.model 'Line', mongoose.Schema {
    type: {type: String}
    user: {type: mongoose.Schema.ObjectId, ref: 'User'}
    content: {type: String}
    data: {type: {}}
    createdAt: {type: Date, default: new Date, index: true}
  }
  Line.modelName = 'Line'
  compound.models.Line = Line

