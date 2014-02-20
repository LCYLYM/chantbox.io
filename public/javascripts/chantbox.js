(function() {
  window.chantbox = angular.module('chantbox', []);

  chantbox.service('Socket', [
    '$rootScope', function($rootScope) {
      var socket;
      return socket = io.connect('', {
        reconnect: true,
        'reconnect delay': 500
      });
    }
  ]);

  chantbox.controller('RoomController', [
    '$scope', 'Socket', function($scope, socket) {
      var join, message;
      $scope.messages = [
        {
          time: new Date,
          type: 'system',
          content: "Connecting..."
        }
      ];
      $scope.users = {};
      socket.on('connect', function() {
        return join();
      });
      socket.on('disconnect', function() {
        return message({
          type: 'system',
          content: 'Disconnected from server... trying to reconnect'
        });
      });
      socket.on('reconnect', function() {
        message({
          type: 'system',
          content: 'Reconnected'
        });
        return join(false);
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
        return message(data);
      });
      $scope.send = function($event) {
        if ($event.which !== 13 || !$event.target.value.trim()) {
          return;
        }
        socket.emit('message', $event.target.value);
        return $event.target.value = '';
      };
      message = function(data) {
        $scope.messages.push({
          time: new Date,
          type: data.type,
          content: data.content,
          user: data.user
        });
        return $scope.$apply();
      };
      return join = function(notify) {
        if (notify == null) {
          notify = true;
        }
        return socket.emit('room:join', $scope.room, $scope.as, notify);
      };
    }
  ]);

}).call(this);
