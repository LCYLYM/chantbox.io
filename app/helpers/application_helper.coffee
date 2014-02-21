module.exports = class ApplicationHelper

  @randomHash: do ->
    hashBank = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    length = hashBank.length
    return (len=7) ->
      string = ''
      string+= hashBank[Math.floor(length*(Math.random()))] for i in [0..len]
      return string

  @avatar = (user, size=normal) ->
    return "<img src='#{user.avatar}' class='avatar #{size}' />"