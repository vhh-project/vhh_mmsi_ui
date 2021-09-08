Chaplin = require 'chaplin'
Model   = require 'models/base/model'
View    = require 'views/base/view'

module.exports = class HeaderView extends View
  autoRender: true
  noWrap: true
  template: require './templates/header'

  events:
    'click #header-button-logout': 'clickLogout'

  initialize: (data) ->
    super(data)
    Chaplin.mediator.subscribe('new-path', @urlChanged)

  attach: ->
    super
    @$navItems = @$el.find('.nav-link')
    @urlChanged(window.location.pathname)

  getTemplateData: ->
    {
      userMe: window.bootstrap.userMe.attributes
      baseUrl: window.settings.baseUrl
    }

  urlChanged: (newPath) =>
    @$navItems.removeClass('active')

    return unless newPath?.length > 0

    if newPath.indexOf('/') != 0
      newPath = "#{window.settings.baseUrl}#{newPath}"

    $navItem = null

    @$navItems.each (index, node) ->
      if newPath.indexOf(node.getAttribute('href')) == 0
        $navItem = $(node)

    $navItem?.addClass('active')

  clickLogout: ->
    $('body').append("""
        <form id="header-logout-form" method="post" action="/logout">
          <input type="hidden" name="_csrf" value="#{Model.getXSRFCookie()}" />
        </form>
      """)

    $('#header-logout-form').submit()
      
