(function() {
  window.chantbox = angular.module('chantbox', []);

  chantbox.service('Socket', [
    '$rootScope', function($rootScope) {
      return io.connect();
    }
  ]);

  chantbox.controller('RoomController', [
    '$scope', 'Socket', function($scope, socket) {
      $scope.messages = [
        {
          time: new Date,
          type: 'system',
          content: "Joining..."
        }
      ];
      $scope.users = {};
      socket.on('connect', function() {
        return socket.emit('room:join', $scope.room, $scope.as);
      });
      socket.on('room:join', function(users) {
        $scope.users = users;
        return $scope.$apply();
      });
      socket.on('room:leave', function(as) {
        delete $scope.users[as];
        return $scope.$apply();
      });
      socket.on('message', function(data) {
        $scope.messages.push({
          time: new Date,
          type: data.type,
          content: data.content,
          user: data.user
        });
        return $scope.$apply();
      });
      return $scope.send = function($event) {
        if ($event.which !== 13 || !$event.target.value.trim()) {
          return;
        }
        socket.emit('message', $event.target.value);
        return $event.target.value = '';
      };
    }
  ]);

}).call(this);
