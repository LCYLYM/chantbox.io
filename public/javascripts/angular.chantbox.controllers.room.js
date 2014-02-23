(function() {
  window.chantbox.controller('RoomController', [
    '$scope', '$timeout', 'Socket', 'Chatter', function($scope, $timeout, socket, Chatter) {
      var connected, join, message, notify, setUsersList;
      (function() {
        return document.getElementById("input").focus();
      })();
      $scope.messages = [];
      $scope.users = {};
      $scope.notification = '';
      connected = false;
      socket.on('connect', function() {
        return notify('Connected', true);
      });
      socket.on('disconnect', function() {
        notify('Disconnected from server... trying to reconnect');
        setUsersList({});
        return connected = false;
      });
      socket.on('reconnect', function() {
        return notify('Reconnected', true);
      });
      socket.on('join', function(users) {
        return setUsersList(users);
      });
      socket.on('ready', function() {
        connected = true;
        return join();
      });
      socket.on('leave', function(as) {
        delete $scope.users[as];
        return $scope.$apply();
      });
      socket.on('message', function(data) {
        return message(data);
      });
      $scope.send = function($event) {
        if ($event.which !== 13 || !$event.target.value.trim() || !connected) {
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
      join = function() {
        return socket.emit('join', $scope.room, location.href.indexOf("fixed=1") > -1);
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
