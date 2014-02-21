module.exports = (mongoose, compound) ->

  User = mongoose.model 'User', mongoose.Schema {
    screen_name: {type: String, index: {unique: true, sparse: true}}
    avatar: String
    createdAt: {type: Date, default: new Date}
  }
  User.modelName = 'User'
  compound.models.User = User


