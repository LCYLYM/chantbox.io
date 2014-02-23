(function() {
  window.chantbox.controller('RoomController', [
    '$scope', '$timeout', '$window', 'Socket', 'Chatter', function($scope, $timeout, $window, socket, Chatter) {
      var audio, chime, connected, focus, join, me, message, notify, setUsersList, title, unread, updateUnreadCounter;
      audio = document.createElement('audio');
      chime = !!(audio.canPlayType && audio.canPlayType('audio/mpeg;').replace(/no/, '')) ? new Audio('/sounds/chime.wav') : false;
      (function() {
        return document.getElementById("input").focus();
      })();
      $scope.messages = [];
      $scope.users = {};
      $scope.notification = '';
      connected = false;
      me = null;
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
      socket.on('ready', function(_me) {
        connected = true;
        me = _me;
        updateUnreadCounter(0);
        return join();
      });
      socket.on('leave', function(users) {
        return setUsersList(users);
      });
      socket.on('message', function(data) {
        if (!focus && ((data.user != null) && data.user.screen_name !== me.screen_name)) {
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
        return socket.emit('join', $scope.room, location.href.indexOf("fixed=1") > -1);
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
