utils     = require 'lib/utils'
View      = require 'views/base/view'
ModalView = require 'views/elements/modal-view'
mediator  = require 'mediator'

# Site view is a top-level view which is bound to body.
module.exports = class SiteView extends View
  container: 'body'
  id: 'site-container'
  regions:
    header: '#header-container'
    main: '#main-container'
  template: require './templates/site'

  events:
    'click .button-open-in-child-window': 'openLinkInChildWindow'

  initialize: (data) ->
    super(data)

    mediator.subscribe('application:ask-discard-edited', @askDiscardEdited)

    unless utils.isChildWindow()
      mediator.subscribe('child-new-path', @childPathChanged)

  attach: ->
    super()

    window.opener?.postMessage({ type: 'child-ready' }) if utils.isChildWindow()

  askDiscardEdited: =>
    new ModalView
      header: lang._('header.discard_edited')
      content: lang._('message.discard_edited')
      confirmText: lang._('button.discard')
      parent: @
      callback: =>
        mediator.publish('application:discard-edited')
        true

  childPathChanged: (path = '') =>
    pathSplitted = path.split('/')

    if pathSplitted.length > 1
      @currentChildPath = "#{pathSplitted[0]}/#{pathSplitted[1]}"
    else  
      @currentChildPath = path

    $('.button-open-in-child-window-active')
      .removeClass('button-open-in-child-window-active')
      .prop('title', lang._('tip.open_in_child_window'))

    $(".button-open-in-child-window[data-url=\"#{window.settings.baseUrl + @currentChildPath}\"]")
      .addClass('button-open-in-child-window-active')
      .prop('title', lang._('tip.opened_in_child_window'))

  openLinkInChildWindow: (event) ->
    event.stopPropagation()

    windowSettings = utils.loadSettings('childWindowSettings', null, 'json')

    if windowSettings?
      left = windowSettings.left
      top = windowSettings.top
      width = windowSettings.width
      height = windowSettings.height

    else
      left = 0
      top = window.screen.availTop
      width = 800
      height = 600

    url = event.currentTarget.dataset.url

    childWindowHandle = window.open(event.currentTarget.dataset.url, 'vhhSecondWindow', "width=#{width},height=#{height},left=#{left},top=#{top}")
    mediator.publish('new-child-window', childWindowHandle)

    if window.settings.baseUrl?.length > 0
      url = url.substr(window.settings.baseUrl.lentght)
    
    mediator.publish('child-new-path', url)
