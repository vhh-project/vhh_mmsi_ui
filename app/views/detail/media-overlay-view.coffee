utils                       = require 'lib/utils'
View                        = require 'views/base/view'
DetailMediaView             = require './media-view'

module.exports = class DetailMediaOverlayView extends View
  autoRender: true
  template: require './templates/media-overlay'
  className: 'detail-media-overlay-view'

  events:
    'click .button-close-media-overlay': 'closeModal'

  initialize: (data) ->
    super(data)

    @closeCallback = data.onClose

  getTemplateData: ->
    {
      mediaType: @model.getMediaType()
      label: @model.getPreferredLabel()
    }

  attach: ->
    super()

    @mediaView = new DetailMediaView
      container: @$el.find('.detail-media-content')
      model: @model

  closeModal: ->
    @remove()
    @closeCallback?(@)

