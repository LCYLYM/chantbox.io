(function() {
  window.chantbox.controller('RoomController', [
    '$scope', 'Socket', 'Chatter', function($scope, socket, Chatter) {
      var join, message, setUsersList;
      (function() {
        return document.getElementById("input").focus();
      })();
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
        message({
          type: 'system',
          content: 'Disconnected from server... trying to reconnect'
        });
        return setUsersList({});
      });
      socket.on('reconnect', function() {
        message({
          type: 'system',
          content: 'Reconnected'
        });
        return join(false);
      });
      socket.on('join', function(users) {
        return setUsersList(users);
      });
      socket.on('leave', function(as) {
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
      join = function(notify) {
        if (notify == null) {
          notify = true;
        }
        return socket.emit('join', $scope.room, notify);
      };
      return setUsersList = function(users) {
        $scope.users = users;
        return $scope.$apply();
      };
    }
  ]);

}).call(this);
