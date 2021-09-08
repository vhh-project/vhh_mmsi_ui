View            = require 'views/base/view'
DetailVideoView = require './video-view'
DetailImageView = require './image-view'


module.exports = class DetailMediaView extends View
  autoRender: true
  className: 'media-view'

  attach: ->
    super()

    representation = @model.getPrimaryRepresentation()

    unless representation?
      @showNoMediaAlert()
      return

    switch representation.mimetype
      # Use image viewer for image files
      when 'image/jpeg', 'image/png'
        @mediaView = new DetailImageView
          model: @model
          container: @$el

      # Use video viewer for video files
      when 'video/mp4'
        @mediaView = new DetailVideoView
          model: @model
          container: @$el

    if @mediaView?
      @subview 'media', @mediaView

    else
      @showNoMediaAlert()

  showNoMediaAlert: ->
    @$el.html("<div class=\"row\"><div class=\"col-12\"><div class=\"alert alert-secondary\">#{lang._('message.no_media_found')}</div></div></div>")

  notifyReattached: ->
    @mediaView.notifyReattached?()