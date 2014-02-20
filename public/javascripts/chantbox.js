(function() {
  window.chantbox = angular.module('chantbox', []);

  chantbox.service('Socket', [
    '$rootScope', function($rootScope) {
      return io.connect();
    }
  ]);

  chantbox.controller('RoomController', [
    '$scope', 'Socket', function($scope, socket) {
      var message;
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
      socket.on('room:join', function(data, users) {
        message('system', "" + data.user.as + " joined " + data.room);
        $scope.users = users;
        return $scope.$apply();
      });
      socket.on('room:leave', function(data) {
        message('system', "" + data.as + " left " + data.room);
        return delete $scope.users[data.as];
      });
      return message = function(type, content, as) {
        $scope.messages.push({
          time: new Date,
          type: type,
          content: content,
          as: as
        });
        return $scope.$apply();
      };
    }
  ]);

}).call(this);
