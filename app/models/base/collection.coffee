Chaplin = require 'chaplin'
Model = require './model'

module.exports = class Collection extends Chaplin.Collection
  # Mixin a synchronization state machine.
  # _(@prototype).extend Chaplin.SyncMachine
  # initialize: ->
  #   super
  #   @on 'request', @beginSync
  #   @on 'sync', @finishSync
  #   @on 'error', @unsync

  # Use the project base model per default, not Chaplin.Model
  model: Model

  fetch: (options = {}) ->
    options.beforeSend = (xhr) =>
      token = Model.getXSRFCookie()
      xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?

      @xhr = xhr

    options.complete = (xhr) =>
      delete @xhr

    super(options)

  # Mocks cache prevention from jQuery, usable for non-GET requests
  addCachePrevention: (url) ->
    return if url.indexOf('_r=') >= 0
    now = new Date
    
    url += if url.indexOf('?') >= 0 then '&' else '?'
    url += '_=' + now.valueOf()




    
