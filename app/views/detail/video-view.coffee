Shots         = require 'models/shots'
View          = require 'views/base/view'
ShotListView  = require 'views/elements/shot-list-view'

module.exports = class DetailVideoView extends View
  autoRender: false
  template: require './templates/video'
  className: 'video-view'

  initialize: ->
    super()

    representation = @model.getPrimaryRepresentation()
          
    if representation?
      @shots = new Shots videoId: representation.representation_id
      @shots.fetch
        success: =>
          @render()

        error: =>
          console.warn 'Shots could not be loaded for this video'
          @render()

    else
      @render()

  attach: ->
    super()
    
    videoData = @model.getPrimaryVideoData()
    mask = @model.getOverscanMask?()

    # Try to get manual shots and take autoshots if necessary
    if @shots?
      shots = @shots.getList(false)

      unless shots?.length > 0
        shots = @shots.getList(true)

    if shots?
      for item in shots
        item.isAuto = item.status == 'A' or item.autoRef?

    $wrapper = @$el.find('.video-player-wrapper')

    if videoData?
      @videoMediator = new VhhVideoMediator

      @videoPlayer = new VhhVideoPlayer
        container: $wrapper
        mediator: @videoMediator
        adjustHeightToContainer: true
        canShowMask: mask?
        showMask: false
        canShowZoom: mask?
        showZoom: false
        calculateFrameOffset: true
        detectFirstFrame: false
        video:
          fps: videoData.fps
          frames: videoData.frames
          isFilm: false
          shots: shots
          mask: mask
          source:
            type: videoData.mimeType
            src: videoData.url
            posterframe: videoData.posterframe

      if videoData.frames?
        @filmStrip = new VhhFilmstrip
          container: @$el.find('.video-filmstrip-wrapper')
          mediator: @videoMediator
          firstFrameNumber: 1
          lastFrameNumber: videoData.frames
          path: videoData.thumbPattern
          pathDigits: videoData.thumbDigits

      @shotListView = new ShotListView
        container: @$el.find('.shot-list-container')
        mediator: @videoMediator
        shots: shots
        video: @videoPlayer.video
        thumbPath: videoData.thumbPattern
        thumbPathDigits: videoData.thumbDigits

      @subview('shot-list', @shotListView)

    else
      @$el.find('.video-player-wrapper').html("<div class=\"alert alert-secondary\">#{lang._('message.no_video_found')}</div>")

  notifyReattached: ->
    @filmStrip?.followCurrentFrame()