window.chantbox.controller 'RoomController', ['$scope', '$timeout', 'Socket', 'Chatter', ($scope, $timeout, socket, Chatter) ->

  do ->
    # focus on input on load
    document.getElementById("input").focus()

  $scope.messages = []
  $scope.users = {}
  $scope.notification = ''
  connected = false
  
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

  socket.on 'ready', ->
    connected = true
    join()

  socket.on 'leave', (as) ->
    delete $scope.users[as]
    $scope.$apply()

  socket.on 'message', (data) ->
    return notify(data.content, true) if data.type is 'system'
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

  join = (notify=true) ->
    socket.emit 'join', $scope.room, notify

  setUsersList = (users) ->
    $scope.users = users
    $scope.$apply()

  #init 
  do ->
    notify "Connecting to ##{$scope.room}..."


]