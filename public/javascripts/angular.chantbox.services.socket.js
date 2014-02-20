(function() {
  window.chantbox.service('Socket', [
    '$rootScope', function($rootScope) {
      var socket;
      return socket = io.connect('', {
        reconnect: true,
        'reconnect delay': 500
      });
    }
  ]);

}).call(this);
