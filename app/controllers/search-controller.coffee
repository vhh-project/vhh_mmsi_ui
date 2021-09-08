Chaplin               = require 'chaplin'
Controller            = require 'controllers/base/controller'
HeaderView            = require 'views/home/header-view'
SearchObjectsView     = require 'views/search/search-objects-view'
SearchAgentsView      = require 'views/search/search-agents-view'
SearchEventsView      = require 'views/search/search-events-view'
SearchPlacesView      = require 'views/search/search-places-view'
SearchCollectionsView = require 'views/search/search-collections-view'

module.exports = class SearchController extends Controller
  beforeAction: (params, route) ->
    super(params, route)
    @reuse 'header', HeaderView, region: 'header'

  objects: ->
    @view = new SearchObjectsView
      region: 'main'

  agents: ->
    @view = new SearchAgentsView
      region: 'main'

  events: ->
    @view = new SearchEventsView
      region: 'main'

  places: ->
    @view = new SearchPlacesView
      region: 'main'

  collections: ->
    @view = new SearchCollectionsView
      region: 'main'

  