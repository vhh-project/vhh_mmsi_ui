# Application routes.
module.exports = (match) ->
  match 'map', 'home#map', params: { title: 'title.map' }
  match 'objects', 'search#objects', params: { title: 'title.objects' }
  match 'objects/:id', 'details#object', constraints: { id: /^\d+$/ }
  match 'objects/create/:typeId', 'create#object', constraints: { typeId: /^\d+$/ }, params: { title: 'title.create_object' }
  match 'objects/:id/:tab', 'details#objectTab', constraints: { id: /^\d+$/ }
  match 'agents', 'search#agents', params: { title: 'title.agents' }
  match 'agents/:id', 'details#agent', constraints: { id: /^\d+$/ }
  match 'agents/create/:typeId', 'create#agent', constraints: { typeId: /^\d+$/ }, params: { title: 'title.create_agent' }
  match 'agents/:id/:tab', 'details#agentTab', constraints: { id: /^\d+$/ }
  match 'events', 'search#events', params: { title: 'title.events' }
  match 'events/:id', 'details#event', constraints: { id: /^\d+$/ }
  match 'events/create/:typeId', 'create#event', constraints: { typeId: /^\d+$/ }, params: { title: 'title.create_event' }
  match 'events/:id/:tab', 'details#eventTab', constraints: { id: /^\d+$/ }
  match 'places', 'search#places', params: { title: 'title.places' }
  match 'places/:id', 'details#place', constraints: { id: /^\d+$/ }
  match 'places/create/:typeId', 'create#place', constraints: { typeId: /^\d+$/ }, params: { title: 'title.create_place' }
  match 'places/:id/:tab', 'details#placeTab', constraints: { id: /^\d+$/ }
  match 'collections', 'search#collections', params: { title: 'title.collections' }
  match 'collections/:id', 'details#collection', constraints: { id: /^\d+$/ }
  match 'collections/create/:typeId', 'create#collection', constraints: { typeId: /^\d+$/ }, params: { title: 'title.create_collection' }
  match 'collections/:id/:tab', 'details#collectionTab', constraints: { id: /^\d+$/ }
  match '*anything', 'home#redirect', params: { route: 'home#map' }
