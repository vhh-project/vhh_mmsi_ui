utils = require 'lib/utils'
View  = require 'views/base/view'

module.exports = class ShotListView extends View
  autoRender: true
  className: 'shot-list-view'
  template: require './templates/shot-list'

  events:
    'click .shot-list-row': 'clickItem'
    'click .btn-in-out': 'clickInOutButton'

  initialize: (data) ->
    super(data)

    @shots = data.shots
    @video = data.video
    
    @mediator = data.mediator
    @mediator?.subscribe('frameUpdate', @)

    @thumbPath = data.thumbPath
    @thumbPathDigits = data.thumbPathDigits

    console.log @shots

    $(window).on('resize', @resize)

    if @thumbPath? and @shots?
      for shot, index in @shots
        shot.shotNumber = index + 1
        shot.smpteIn = @video.formatVideoTime(@video.convertToVideoTime(shot.in), 'smpte')
        shot.smpteOut = @video.formatVideoTime(@video.convertToVideoTime(shot.out), 'smpte')

        paddedIndexIn = utils.padStart(shot.in, @thumbPathDigits, '0')
        shot.thumbIn = @thumbPath.replace('%s', paddedIndexIn)

  getTemplateData: ->
    {
      shots: @shots
    }

  attach: ->
    super()

    @activateTooltips()
    @resize()

  resize: =>
    @$el.css('height', '')
    @$el.css('height', $(window).height() - @$el.offset().top - 12)

  # Called by the video mediator
  frameUpdate: (frameNumber) ->
    @setCurrentFrame(frameNumber)
  
  clickItem: (event) ->
    index = parseInt(event.currentTarget.dataset.index)
    shot = @shots[index]

    @mediator?.setFrame(shot.in)

  clickInOutButton: (event) ->
    event.stopPropagation()
    @mediator?.setFrame(parseInt(event.currentTarget.dataset.value))

  setCurrentFrame: (frameNumber) ->
    index = @video.getCurrentShotIndex(frameNumber)

    if @currentIndex? and @currentIndex != index
      @$el.find(".shot-list-item-#{@currentIndex}").removeClass('active')

    @currentIndex = index

    if index?
      @$el.find(".shot-list-item-#{index}").addClass('active')

    @positionActiveShot()

  positionActiveShot: ->
    $activeItem = @$el.find(".shot-list-row.active")
    return unless $activeItem.length == 1

    top = $activeItem.position().top
    bottom = top + $activeItem.outerHeight()

    if top < 0 or bottom > @$el.height()
      @$el.scrollTop(top + @$el.scrollTop() - (@$el.height() / 2))

  remove: ->
    @mediator?.unsubscribe('frameUpdate', @)
    
    super()