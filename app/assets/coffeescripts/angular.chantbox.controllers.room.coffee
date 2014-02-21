window.chantbox.controller 'RoomController', ['$scope', 'Socket', 'Chatter', ($scope, socket, Chatter) ->

  do ->
    # focus on input on load
    document.getElementById("input").focus()

  $scope.messages = [{time: new Date, type: 'system', content: "Connecting..."}]
  $scope.users = {}
  
  socket.on 'connect', ->
    join()

  socket.on 'disconnect', ->
    message {type: 'system', content: 'Disconnected from server... trying to reconnect'} 
    $scope.users = {} # empty users list when disconnected from room

  socket.on 'reconnect', ->
    message {type: 'system', content: 'Reconnected'}
    join(false)

  socket.on 'join', (users) ->
    $scope.users = users
    $scope.$apply()

  socket.on 'leave', (as) ->
    delete $scope.users[as]
    $scope.$apply()

  socket.on 'message', (data) ->
    message data

  $scope.send = ($event) ->
    return if $event.which isnt 13 or not $event.target.value.trim()
    socket.emit 'message', $event.target.value
    $event.target.value = ''

  message = (data) ->
    $scope.messages.push {time: new Date, type: data.type, content: data.content, user: data.user}
    $scope.$apply()
    # scroll to bottom of chatter when a message is received
    Chatter.scrollToBottom()

  join = (notify=true) ->
    socket.emit 'join', $scope.room, $scope.as, notify

]