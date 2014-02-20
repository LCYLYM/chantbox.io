window.chantbox.service 'Socket', ['$rootScope', ($rootScope) ->
  socket = io.connect '', {reconnect: true, 'reconnect delay': 500}
]