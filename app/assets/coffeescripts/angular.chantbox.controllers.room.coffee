window.chantbox.controller 'RoomController', ['$scope', '$timeout', '$window', 'Socket', 'Chatter', ($scope, $timeout, $window, socket, Chatter) ->

  audio = document.createElement('audio');
  chime = if !!(audio.canPlayType && audio.canPlayType('audio/mpeg;').replace(/no/, '')) then new Audio('/sounds/chime.wav') else false

  # scope vars
  $scope.messages = []
  $scope.users = {}
  $scope.notification = ''
  $scope.room = {}
  $scope.me = null
  $scope.url = location.href.split("?")[0]

  $input = angular.element(document.getElementById("input"))
  do ($input) ->
    # focus on input on load
    $input[0].focus()
    $input.on 'keyup', ->
      setStatus()

  # instance vars
  connected = false
  focused = true
  unread = 0
  title = document.title
  _status = ''

  message = (data) ->
    $scope.messages.push {time: new Date, type: data.type, content: data.content, user: data.user}
    $scope.$apply()
    Chatter.scrollToBottom() # scroll to bottom of chatter when a message is received

  notify = (m, fadeOut) ->
    clear = -> $scope.notification = null
    if m
      $scope.notification = m
    else
      $timeout clear, 1000 if not m

    $timeout(clear, 2000) if fadeOut

  join = ->
    fixed = (location.href.indexOf("fixed=1") > -1)
    getHistory = $scope.messages.length==0
    socket.emit 'join', $scope.roomName, fixed, getHistory

  setUsersList = (users) ->
    $scope.users = users
    $scope.$apply()

  updateUnreadCounter = (c) ->
    unread = c
    document.title = (if unread then "(#{unread}) " else '') + title

  setStatus = ->
    t = null
    do ->
      if $input.val() 
        status = 'Typing...'
      else if focused 
        status = 'Online'
      else if not focused 
        status = 'Away'
      if _status isnt status
        _status = status
        socket.emit 'status', status

        clearTimeout(t) if typeof(t) is 'number'
        t = setTimeout ->
          _status = 'Idle'
          socket.emit 'status', _status
        , 60*1000 

  # window events
  angular.element($window).on 'blur', ->
    focused = false
    setStatus()

  angular.element($window).on 'focus', ->
    focused = true
    updateUnreadCounter 0
    setStatus()

  angular.element($window).on 'mousemove', ->
    setStatus()
  
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

  socket.on 'room', (room, me) ->
    $scope.room = room
    $scope.me = me
    $scope.$apply()

  socket.on 'ready', ->
    connected = true
    updateUnreadCounter 0
    setStatus()
    join()

  socket.on 'leave', (users) ->
    setUsersList users

  socket.on 'message', (data) ->
    # return notify(data.content, true) if data.type is 'system'
    if not focused and (data.user? and data.user.screen_name isnt $scope.me.screen_name) # not focused, not me
      updateUnreadCounter ++unread 
      chime.play() if chime and data.type isnt 'system'
    message data

  socket.on 'status', (screen_name, status) ->
    if $scope.users[screen_name]
      $scope.users[screen_name].status = status
      $scope.$apply()

  $scope.send = ($event) ->
    return if $event.which isnt 13 or not $event.target.value.trim() or not connected
    socket.emit 'message', $event.target.value
    $event.target.value = ''
    setStatus()

  #init 
  do ->
    notify "Connecting to ##{$scope.room}..."

]