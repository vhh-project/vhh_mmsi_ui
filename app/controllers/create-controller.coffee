utils         = require 'lib/utils'
Chaplin       = require 'chaplin'
Controller    = require 'controllers/base/controller'
CaObject      = require 'models/ca-object'
CaEntity      = require 'models/ca-entity'
CaOccurrence  = require 'models/ca-occurrence'
CaPlace       = require 'models/ca-place'
CaCollection  = require 'models/ca-collection'
HeaderView    = require 'views/home/header-view'
CreateView    = require 'views/create/create-view'

module.exports = class CreateController extends Controller
  beforeAction: (params, route) ->
    super(params, route)
    @reuse 'header', HeaderView, region: 'header'

  checkAndRedirect: ->
    isChildWindow = utils.isChildWindow()
    
    if isChildWindow
      Chaplin.utils.redirectTo('search#objects')

    isChildWindow

  object: (data) ->
    return if @checkAndRedirect()

    @view = new CreateView
      region: 'main'
      model: CaObject
      typeId: data.typeId
      detailRoute: 'details#object'
      parentBreadcrumb:
        label: 'breadcrumbs.objects'
        route: 'search#objects'

  agent: (data) ->
    return if @checkAndRedirect()

    @view = new CreateView
      region: 'main'
      typeId: data.typeId
      model: CaEntity
      detailRoute: 'details#agent'
      parentBreadcrumb:
        label: 'breadcrumbs.agents'
        route: 'search#agents'

  event: (data) ->
    return if @checkAndRedirect()
    
    @view = new CreateView
      region: 'main'
      model: CaOccurrence
      typeId: data.typeId
      detailRoute: 'details#event'
      parentBreadcrumb:
        label: 'breadcrumbs.events'
        route: 'search#events'

  place: (data) ->
    return if @checkAndRedirect()

    @view = new CreateView
      region: 'main'
      model: CaPlace
      typeId: data.typeId
      detailRoute: 'details#place'
      parentBreadcrumb:
        label: 'breadcrumbs.places'
        route: 'search#places'

  collection: (data) ->
    return if @checkAndRedirect()

    @view = new CreateView
      region: 'main'
      model: CaCollection
      typeId: data.typeId
      detailRoute: 'details#collection'
      parentBreadcrumb:
        label: 'breadcrumbs.collections'
        route: 'search#collections'