Chaplin     = require 'chaplin'
Controller  = require 'controllers/base/controller'
HeaderView  = require 'views/home/header-view'
MapView     = require 'views/home/map-view'

module.exports = class HomeController extends Controller
  beforeAction: (params, route) ->
    super(params, route)
    @reuse 'header', HeaderView, region: 'header'

  redirect: (data) ->
    return unless data?.route?
    Chaplin.utils.redirectTo(data.route)

  map: ->
    @view = new MapView
      region: 'main'
