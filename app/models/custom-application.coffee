utils       = require 'lib/utils'
Application = require 'application'
Backbone    = require 'backbone'
View        = require 'views/base/view'
mediator    = require 'mediator'

module.exports = class CustomApplication extends Application
  customOptions:
    isEditing: false
    beforeEditDispatcherData: null
    childWindowHandle: null

  initialize: (data) ->
    super(data)
    
    if utils.isChildWindow()
      @persistChildWindowSettings()
      mediator.subscribe('new-path', @urlChanged)
      @listenToParentMessages()

    else
      @listenToChildMessages()

  initDispatcher: (options) ->
    super(options)
    mediator.unsubscribe('router:match')
    mediator.subscribe('router:match', @dispatcherHook)
    mediator.subscribe('application:editing', @setEditing)
    mediator.subscribe('application:discard-edited', @discardEditing)
    mediator.subscribe('map:overlays-updated', @mapOverlaysUpdated)
    window.addEventListener('beforeunload', @onBeforeunload)
    window.addEventListener('onunload', @onUnload)

  dispatcherHook: (route, actionParams, options) =>
    @customOptions.beforeEditDispatcherData = null

    if @customOptions.isEditing == true
      @customOptions.beforeEditDispatcherData =
        route: route
        actionParams: actionParams
        options: options

      navigateOptions =
        trigger: false
        replace: false

      Backbone.history.navigate(@dispatcher.currentRoute.path, navigateOptions)
      mediator.publish('application:ask-discard-edited')

    else
      @dispatcher.dispatch(route, actionParams, options)

  persistChildWindowSettings: ->
    getWindowSettings = ->
      {
        left: window.screenLeft
        top: window.screenTop
        width: window.innerWidth
        height: window.innerHeight
      }

    window.setInterval(
      ->
        if window.windowSettings?
          return if windowSettings.left == window.screenLeft and
            windowSettings.top == window.screenTop and
            windowSettings.width == window.innerWidth and
            windowSettings.height == window.innerHeight

          window.windowSettings = getWindowSettings()
          utils.saveSettings('childWindowSettings', window.windowSettings)

        else
          window.windowSettings = getWindowSettings()

      , 1000
    )

  listenToChildMessages: ->
    mediator.subscribe('new-child-window', @registerChildWindow)
    window.addEventListener('message', @receiveChildMessage)

  listenToParentMessages: ->
    window.addEventListener('message', @receiveParentMessage)

  urlChanged: (newPath) =>
    window.opener?.postMessage({ type: 'new-path', path: newPath }, '*');

  registerChildWindow: (childWindowHandle) =>
    @customOptions.childWindowHandle = childWindowHandle

  receiveChildMessage: (event) =>
    return unless event.data? and event.origin == window.location.origin

    console.log('message from child received:', event.data)
    
    switch event.data.type
      when 'new-path'
        mediator.publish('child-new-path', event.data.path)

      when 'child-ready'
        @mapOverlaysUpdated(View.mapImageOverlays)

      when 'map-overlays-updated'
        View.mapImageOverlays = event.data.imageOverlays

  receiveParentMessage: (event) =>
    return unless event.data? and event.origin == window.location.origin

    console.log('message from parent received:', event.data)
    
    switch event.data.type
      when 'map-overlays-updated'
        View.mapImageOverlays = event.data.imageOverlays

  onBeforeunload: (event) =>
    return unless @customOptions.isEditing == true
    event.returnValue = lang._('message.discard_before_unload')

  setEditing: (isEditing) =>
    @customOptions.isEditing = isEditing

  discardEditing: =>
    @setEditing(false)
    return unless @customOptions.beforeEditDispatcherData?

    data = @customOptions.beforeEditDispatcherData

    navigateOptions =
      trigger: false
      replace: true

    Backbone.history.navigate(data.route.path, navigateOptions)

    @dispatcherHook(data.route, data.actionParams, data.options)

  mapOverlaysUpdated: (imageOverlays) =>
    if utils.isChildWindow()
      window.opener?.postMessage({ type: 'map-overlays-updated',  imageOverlays: imageOverlays }, '*')

    else
      @customOptions.childWindowHandle?.postMessage({ type: 'map-overlays-updated',  imageOverlays: imageOverlays }, '*')




