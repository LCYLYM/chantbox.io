(function() {
  window.chantbox.service('Chatter', [
    '$window', '$timeout', function($window, $timeout) {
      var $chatter, first, resize, scrollToBottom, t;
      $chatter = document.querySelector("#chatter ul");
      scrollToBottom = function() {
        return $chatter.scrollTop = $chatter.scrollHeight;
      };
      if ($chatter) {
        t = null;
        first = true;
        resize = (function() {
          if (typeof t === 'number') {
            clearTimeout(t);
          }
          t = $timeout(function() {
            $chatter.style.height = $window.innerHeight - 90 + 'px';
            $chatter.style.width = $window.innerWidth - 310 + 'px';
            if (first) {
              first = false;
              return scrollToBottom();
            }
          }, 300);
          return arguments.callee;
        })();
        $window.addEventListener('resize', resize, false);
      }
      return {
        scrollToBottom: scrollToBottom
      };
    }
  ]);

}).call(this);
