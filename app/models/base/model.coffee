Chaplin = require 'chaplin'
# Base model.
module.exports = class Model extends Chaplin.Model
  # Mixin a synchronization state machine.
  # _(@prototype).extend Chaplin.SyncMachine
  # initialize: ->
  #   super
  #   @on 'request', @beginSync
  #   @on 'sync', @finishSync
  #   @on 'error', @unsync

  @getXSRFCookie: ->
    return null unless document.cookie?.length > 0

    splitted = document.cookie.split(';')

    for string in splitted
      string = _.trim(string)
      keyValue = string.split('=')

      if keyValue.length == 2 and keyValue[0].toLowerCase() == 'xsrf-token'
        return keyValue[1]

    null

  fetch: (options = {}) ->
    options.beforeSend = (xhr) =>
      token = Model.getXSRFCookie()
      xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?
      
      @xhr = xhr

    options.complete = (xhr) =>
      delete @xhr

    super(options)

  save: (attrs, options = {}) ->
    options.beforeSend = (xhr) =>
      token = Model.getXSRFCookie()
      xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?
      
      @xhr = xhr

    options.complete = (xhr) =>
      delete @xhr

    super(attrs, options)
  
  getf: (key) ->
    @get key

  get: (key, split = true) ->
    if split
      splittedKeys = if split then key.split('.') else key

      currentAttribute = @attributes

      for splittedKey in splittedKeys
        currentAttribute = currentAttribute[splittedKey]
        return null unless currentAttribute?

      return currentAttribute

    else
      super key