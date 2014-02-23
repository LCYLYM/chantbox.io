exports.routes = (map)->

  map.root  'application#index'
  map.get   'r/:room', 'application#room'

  map.get   'auth/twitter', 'auth#twitter'
  map.get   'auth/logout', 'auth#logout'
