exports.routes = (map)->

  map.root  'application#index'
  map.get   ':room', 'rooms#index'

  map.get   'auth/twitter', 'auth#twitter'
  map.get   'auth/logout', 'auth#logout'
