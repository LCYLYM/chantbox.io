window.chantbox.controller 'RoomController', ['$scope', '$timeout', '$window', 'Socket', 'Chatter', ($scope, $timeout, $window, socket, Chatter) ->

  audio = document.createElement('audio');
  chime = if !!(audio.canPlayType && audio.canPlayType('audio/mpeg;').replace(/no/, '')) then new Audio('/sounds/chime.wav') else false

  do ->
    # focus on input on load
    document.getElementById("input").focus()

  # scope vars
  $scope.messages = []
  $scope.users = {}
  $scope.notification = ''

  # instance vars
  connected = false
  me = null
  focus = true
  unread = 0
  title = document.title

  # window events
  angular.element($window).on 'blur', -> 
    focus = false

  angular.element($window).on 'focus', ->
    focus = true
    updateUnreadCounter 0
  
  socket.on 'connect', ->
    notify 'Connected', true

  socket.on 'disconnect', ->
    notify 'Disconnected from server... trying to reconnect'
    setUsersList {} # empty users list when disconnected from room
    connected = false

  socket.on 'reconnect', ->
    notify 'Reconnected', true

  socket.on 'join', (users) ->
    setUsersList users

  socket.on 'ready', (_me) ->
    connected = true
    me = _me
    updateUnreadCounter 0
    join()

  socket.on 'leave', (users) ->
    setUsersList users

  socket.on 'message', (data) ->
    # return notify(data.content, true) if data.type is 'system'
    if not focus and (data.user? and data.user.screen_name isnt me.screen_name) # not focused, not me
      updateUnreadCounter ++unread 
      chime.play() if chime and data.type isnt 'system'
    message data

  $scope.send = ($event) ->
    return if $event.which isnt 13 or not $event.target.value.trim() or not connected
    socket.emit 'message', $event.target.value
    $event.target.value = ''

  message = (data) ->
    $scope.messages.push {time: new Date, type: data.type, content: data.content, user: data.user}
    $scope.$apply()
    # scroll to bottom of chatter when a message is received
    Chatter.scrollToBottom()

  notify = (m, fadeOut) ->
    clear = -> $scope.notification = null
    if m
      $scope.notification = m
    else
      $timeout clear, 1000 if not m

    if fadeOut
      $timeout clear, 2000

  join = ->
    socket.emit 'join', $scope.room, (location.href.indexOf("fixed=1") > -1)

  setUsersList = (users) ->
    $scope.users = users
    $scope.$apply()

  updateUnreadCounter = (c) ->
    unread = c
    document.title = (if unread then "(#{unread}) " else '') + title

  #init 
  do ->
    notify "Connecting to ##{$scope.room}..."

]