(function() {
  window.chantbox.controller('RoomController', [
    '$scope', 'Socket', 'Chatter', function($scope, socket, Chatter) {
      var i, join, message, _i;
      $scope.messages = [
        {
          time: new Date,
          type: 'system',
          content: "Connecting..."
        }
      ];
      for (i = _i = 0; _i <= 20; i = ++_i) {
        $scope.messages.push({
          time: new Date,
          type: 'system',
          content: 'lorem upsum dolor sit amet ' + i
        });
      }
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
        $scope.$apply();
        return Chatter.scrollToBottom();
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
