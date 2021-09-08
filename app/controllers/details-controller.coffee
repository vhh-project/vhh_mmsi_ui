Controller            = require 'controllers/base/controller'
HeaderView            = require 'views/home/header-view'
DetailObjectView      = require 'views/detail/detail-object-view'
DetailEntityView      = require 'views/detail/detail-entity-view'
DetailEventView       = require 'views/detail/detail-event-view'
DetailPlaceView       = require 'views/detail/detail-place-view'
DetailCollectionView  = require 'views/detail/detail-collection-view'

module.exports = class DetailsController extends Controller
  beforeAction: (params, route) ->
    super(params, route)
    @reuse 'header', HeaderView, region: 'header'

  object: (data) ->
    @view = new DetailObjectView
      region: 'main'
      id: data.id
      tabRoute: 'details#objectTab'
      tab: data.tab

  objectTab: (data) ->
    @object(data)

  agent: (data) ->
    @view = new DetailEntityView
      region: 'main'
      id: data.id
      tabRoute: 'details#agentTab'
      tab: data.tab

  agentTab: (data) ->
    @agent(data)

  event: (data) ->
    @view = new DetailEventView
      region: 'main'
      id: data.id
      tabRoute: 'details#eventTab'
      tab: data.tab

  eventTab: (data) ->
    @event(data)
  
  place: (data) ->
    @view = new DetailPlaceView
      region: 'main'
      id: data.id
      tabRoute: 'details#placeTab'
      tab: data.tab

  placeTab: (data) ->
    @place(data)

  collection: (data) ->
    @view = new DetailCollectionView
      region: 'main'
      id: data.id
      tabRoute: 'details#collectionTab'
      tab: data.tab

  collectionTab: (data) ->
    @collection(data)
