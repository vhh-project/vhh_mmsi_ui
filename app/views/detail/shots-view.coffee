View          = require 'views/base/view'
EditShotsView  = require 'views/elements/edit-shots-view'

module.exports = class DetailShotsView extends View
  autoRender: true
  template: require './templates/shots'
  className: 'shots-view video-view'


  attach: ->
    super()
    
    videoData = @model.getPrimaryVideoData()
    mask = @model.getOverscanMask?()
    representation = @model.getPrimaryRepresentation()

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
          shots: null
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

      @shotListView = new EditShotsView
        container: @$el.find('.shot-list-container')
        mediator: @videoMediator
        videoId: representation?.representation_id
        video: @videoPlayer.video
        lastFrameNumber: videoData.frames
        thumbPath: videoData.thumbPattern
        thumbPathDigits: videoData.thumbDigits

      @subview('shot-list', @shotListView)

    else
      @$el.find('.video-player-wrapper').html("<div class=\"alert alert-secondary\">#{lang._('message.no_video_found')}</div>")

  notifyReattached: ->
    @filmStrip?.followCurrentFrame()