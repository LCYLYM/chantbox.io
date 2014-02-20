exports.routes = (map)->

  map.root 'application#index'
  map.get ':room', 'rooms#index'

