View = require 'views/base/view'

# A flexible modal overlay
module.exports = class ModalView extends View
  autoRender: true
  id: 'modal-overlay'
  container: 'body'
  containerMethod: 'append'
  template: require 'views/elements/templates/modal'

  _data: null
  _freezed: false
  
  events:
    'click #modal-button-confirm': '_clickOk'
    'click #modal-button-confirm-2': '_clickOk2'
    'click #modal-button-cancel': '_clickCancel'
  
  initialize: (data) ->
    super(data)
    
    @_data = data
    
    data.parent.subview('modal', @) if data.parent?

    if data.preventUrlChange == true
      app.dispatcher.addDispatchHook 'modal-view', -> false

      window.addEventListener 'beforeunload', @beforeunload

    @renderedCallback = data.renderedCallback
        
  # Disables buttons
  freeze: ->
    @_freezed = true
  
  # Enables buttons
  unfreeze: ->
    @_freezed = false
  
  render: ->
    content = if @_data.html? and @_data.html then @_data.content else "<p>#{@_data.content}</p>"
    
    @$el.html @template
      header: @_data.header
      content: new Handlebars.SafeString content
      large: @_data.large == true
      confirm: if @_data.confirmText? then @_data.confirmText else 'Ok'
      confirm2: @_data.confirmText2
      cancel: if @_data.cancelText? then @_data.cancelText else 'Cancel'
      noButtons: @_data.noButtons
      noCancel: @_data.noCancel
        
  attach: ->
    super()

    @$modal = @$el.find('#modal-main')
    
    @$modal
      .modal('show')
      .on 'hidden.bs.modal', =>
        @remove()
        @hiddenCallback?()
      .on 'shown.bs.modal', =>
        # If autofocus attribute is set, try to focus the element and select the input value
        if @_data.autofocus?
          $(@_data.autofocus).select().focus()

        @renderedCallback?(@)

  remove: ->
    @$modal
      .off 'hidden.bs.modal'
      .off 'shown.bs'
    
  # Handles clicks on the OK button
  _clickOk: (event) ->
    return false if @_freezed
    
    result = @_data.callback(@$el.find('.modal-content'), @)
    
    if typeof result == 'function'
      @hiddenCallback = result
      result = true

    else if not result?
      result = true
    
    if result == true
      @$modal.modal('hide')
    
    else
      @unfreeze
  
  # Handles clicks on the second OK button (if present)
  _clickOk2: ->
    return if @_freezed
    
    @_data.callback2()
    @$modal.modal('hide') if @closeOnButton2
  
  # Handles clicks on the cancel button
  _clickCancel: ->
    return if @_freezed

    @$modal.modal('hide')
    @_data.cancelCallback?()
  


  