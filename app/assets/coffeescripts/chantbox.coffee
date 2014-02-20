window.chantbox = angular.module 'chantbox', []

chantbox.service 'Socket', ['$rootScope', ($rootScope) ->
  io.connect()
]

chantbox.controller 'RoomController', ['$scope', 'Socket', ($scope, socket) ->
  $scope.messages = [{time: new Date, type: 'system', content: "Joining..."}]
  $scope.users = {}
  
  socket.on 'connect', ->
    socket.emit 'room:join', $scope.room, $scope.as

  socket.on 'room:join', (users) ->
    $scope.users = users
    $scope.$apply()

  socket.on 'room:leave', (as) ->
    delete $scope.users[as]
    $scope.$apply()

  socket.on 'message', (data) ->
    $scope.messages.push {time: new Date, type: data.type, content: data.content, user: data.user}
    $scope.$apply()

  $scope.send = ($event) ->
    return if $event.which isnt 13 or not $event.target.value.trim()
    socket.emit 'message', $event.target.value
    $event.target.value = ''


]