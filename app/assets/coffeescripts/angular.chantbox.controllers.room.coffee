window.chantbox.controller 'RoomController', ['$scope', 'Socket', 'Chatter', ($scope, socket, Chatter) ->
  $scope.messages = [{time: new Date, type: 'system', content: "Connecting..."}]
  for i in [0..20]
    $scope.messages.push {time: new Date, type: 'system', content: 'lorem upsum dolor sit amet ' + i}
  $scope.users = {}
  
  socket.on 'connect', ->
    join()

  socket.on 'disconnect', ->
    message {type: 'system', content: 'Disconnected from server... trying to reconnect'} 

  socket.on 'reconnect', ->
    message {type: 'system', content: 'Reconnected'}
    join(false)

  socket.on 'room:join', (users) ->
    $scope.users = users
    $scope.$apply()

  socket.on 'room:leave', (as) ->
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
    Chatter.scrollToBottom()

  join = (notify=true) ->
    socket.emit 'room:join', $scope.room, $scope.as, notify

]