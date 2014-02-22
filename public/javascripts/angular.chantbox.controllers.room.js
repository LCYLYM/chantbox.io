(function() {
  window.chantbox.controller('RoomController', [
    '$scope', '$timeout', 'Socket', 'Chatter', function($scope, $timeout, socket, Chatter) {
      var join, message, notify, setUsersList;
      (function() {
        return document.getElementById("input").focus();
      })();
      $scope.messages = [];
      $scope.users = {};
      $scope.notification = '';
      socket.on('connect', function() {
        notify('Connected', true);
        return join();
      });
      socket.on('disconnect', function() {
        notify('Disconnected from server... trying to reconnect');
        return setUsersList({});
      });
      socket.on('reconnect', function() {
        notify('Reconnected');
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
        if (data.type === 'system') {
          return notify(data.content, true);
        }
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
      notify = function(m, fadeOut) {
        var clear;
        clear = function() {
          return $scope.notification = null;
        };
        if (m) {
          $scope.notification = m;
        } else {
          if (!m) {
            $timeout(clear, 1000);
          }
        }
        if (fadeOut) {
          return $timeout(clear, 2000);
        }
      };
      join = function(notify) {
        if (notify == null) {
          notify = true;
        }
        return socket.emit('join', $scope.room, notify);
      };
      setUsersList = function(users) {
        $scope.users = users;
        return $scope.$apply();
      };
      return (function() {
        return notify("Connecting to #" + $scope.room + "...");
      })();
    }
  ]);

}).call(this);
