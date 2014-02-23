(function() {
  window.chantbox.controller('RoomController', [
    '$scope', '$timeout', '$window', 'Socket', 'Chatter', function($scope, $timeout, $window, socket, Chatter) {
      var audio, chime, connected, focus, join, message, notify, setUsersList, title, unread, updateUnreadCounter;
      audio = document.createElement('audio');
      chime = !!(audio.canPlayType && audio.canPlayType('audio/mpeg;').replace(/no/, '')) ? new Audio('/sounds/chime.wav') : false;
      (function() {
        return document.getElementById("input").focus();
      })();
      $scope.messages = [];
      $scope.users = {};
      $scope.notification = '';
      $scope.room = {};
      $scope.me = null;
      $scope.url = location.href.split("?")[0];
      connected = false;
      focus = true;
      unread = 0;
      title = document.title;
      angular.element($window).on('blur', function() {
        return focus = false;
      });
      angular.element($window).on('focus', function() {
        focus = true;
        return updateUnreadCounter(0);
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
      socket.on('ready', function(me) {
        connected = true;
        updateUnreadCounter(0);
        return join();
      });
      socket.on('leave', function(users) {
        return setUsersList(users);
      });
      socket.on('message', function(data) {
        if (!focus && ((data.user != null) && data.user.screen_name !== $scope.me.screen_name)) {
          updateUnreadCounter(++unread);
          if (chime && data.type !== 'system') {
            chime.play();
          }
        }
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
      return (function() {
        return notify("Connecting to #" + $scope.room + "...");
      })();
    }
  ]);

}).call(this);
