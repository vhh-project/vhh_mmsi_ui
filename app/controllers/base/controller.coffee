utils     = require 'lib/utils'
Chaplin   = require 'chaplin'
SiteView  = require 'views/site-view'

module.exports = class Controller extends Chaplin.Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: (params, route) ->
    title = if params.title? then lang._(params.title) else null
    utils.setPageTitle(title)

    Chaplin.mediator.publish('new-path', route.path)
    @reuse 'site', SiteView
