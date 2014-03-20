(function() {
  window.chantbox.controller('RoomController', [
    '$scope', '$timeout', '$window', 'Socket', 'Chatter', function($scope, $timeout, $window, socket, Chatter) {
      var $input, audio, chime, connected, focused, join, message, notify, setStatus, setUsersList, title, unread, updateUnreadCounter, _status;
      audio = document.createElement('audio');
      chime = !!(audio.canPlayType && audio.canPlayType('audio/mpeg;').replace(/no/, '')) ? new Audio('/sounds/chime.wav') : false;
      $scope.messages = [];
      $scope.users = {};
      $scope.notification = '';
      $scope.room = {};
      $scope.me = null;
      $scope.url = location.href.split("?")[0];
      $input = angular.element(document.getElementById("input"));
      (function($input) {
        $input[0].focus();
        return $input.on('keyup', function() {
          return setStatus();
        });
      })($input);
      connected = false;
      focused = true;
      unread = 0;
      title = document.title;
      _status = '';
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
        var fixed, getHistory;
        fixed = location.href.indexOf("fixed=1") > -1;
        getHistory = $scope.messages.length === 0;
        return socket.emit('join', $scope.roomName, fixed, getHistory);
      };
      setUsersList = function(users) {
        $scope.users = users;
        return $scope.$apply();
      };
      updateUnreadCounter = function(c) {
        unread = c;
        return document.title = (unread ? "(" + unread + ") " : '') + title;
      };
      setStatus = (function() {
        var t;
        t = null;
        return function() {
          var status;
          if ($input.val()) {
            status = 'Typing...';
          } else {
            status = 'Online';
          }
          if (_status !== status) {
            _status = status;
            socket.emit('status', status);
            if (typeof t === 'number') {
              clearTimeout(t);
            }
            return t = setTimeout(function() {
              _status = 'Away';
              return socket.emit('status', _status);
            }, 30 * 1000);
          }
        };
      })();
      angular.element($window).on('blur', function() {
        return focused = false;
      });
      angular.element($window).on('focus', function() {
        focused = true;
        updateUnreadCounter(0);
        return setStatus();
      });
      angular.element($window).on('mousemove', function() {
        return setStatus();
      });
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
      socket.on('room', function(room, me) {
        $scope.room = room;
        $scope.me = me;
        return $scope.$apply();
      });
      socket.on('ready', function() {
        connected = true;
        updateUnreadCounter(0);
        setStatus();
        return join();
      });
      socket.on('leave', function(users) {
        return setUsersList(users);
      });
      socket.on('message', function(data) {
        if (!focused && ((data.user != null) && data.user.screen_name !== $scope.me.screen_name)) {
          updateUnreadCounter(++unread);
          if (chime && data.type !== 'system') {
            chime.play();
          }
        }
        return message(data);
      });
      socket.on('status', function(screen_name, status) {
        if ($scope.users[screen_name]) {
          $scope.users[screen_name].status = status;
          return $scope.$apply();
        }
      });
      $scope.send = function($event) {
        if ($event.which !== 13 || !$event.target.value.trim() || !connected) {
          return;
        }
        socket.emit('message', $event.target.value);
        $event.target.value = '';
        return setStatus();
      };
      return (function() {
        return notify("Connecting to #" + $scope.room.name + "...");
      })();
    }
  ]);

}).call(this);
