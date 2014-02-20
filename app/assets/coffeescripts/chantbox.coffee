window.chantbox = angular.module 'chantbox', []

chantbox.service 'Socket', ['$rootScope', ($rootScope) ->
  io.connect()
]

chantbox.controller 'RoomController', ['$scope', 'Socket', ($scope, socket) ->
  $scope.messages = [{time: new Date, type: 'system', content: "Joining..."}]
  $scope.users = {}
  
  socket.on 'connect', ->
    socket.emit 'room:join', $scope.room, $scope.as

  socket.on 'room:join', (data, users) ->
    message 'system', "#{data.user.as} joined #{data.room}"
    $scope.users = users
    $scope.$apply()

  socket.on 'room:leave', (data) ->
    message 'system', "#{data.as} left #{data.room}"
    delete $scope.users[data.as]
    
  message = (type, content, as) ->
    $scope.messages.push {time: new Date, type: type, content: content, as: as}
    $scope.$apply()


]