Shots       = require 'models/shots'
ManualShots = require 'models/manual-shots'
utils       = require 'lib/utils'
mediator    = require 'mediator'
View        = require 'views/base/view'
ModalView   = require 'views/elements/modal-view'

module.exports = class EditShotsView extends View
  autoRender: false
  className: 'edit-shots-view'
  template: require './templates/edit-shots'
  shotTemplate: require './templates/edit-shot-item'
  changeShotTypeTemplate: require './templates/change-shot-type'
  interThumbTemplate: require './templates/edit-shot-inter-thumb'
  shotTypes: [ 'NA', 'CU', 'MS', 'LS', 'ELS', 'I']
  currentFrame: 1

  showAll: true

  events:
    'click .shot-in': 'clickShotThumb'
    'click .shot-out': 'clickShotThumb'
    'click .button-create-shot-from-gap': 'clickCreateShotFromGap'
    'click .button-split-shot-before': 'clickSplitShotBefore'
    'click .button-split-shot-after': 'clickSplitShotAfter'
    'click .button-merge-shots': 'clickMergeShots'
    'click .button-move-up-shots': 'clickMoveUp'
    'click .button-move-down-shots': 'clickMoveDown'
    'click .button-change-shot-type': 'clickChangeShotType'
    'click .button-delete-shot': 'clickDeleteShot'
    'click #edit-shots-button-save': 'clickSave'
    'click #edit-shots-button-undo': 'clickUndo'
    'click #edit-shots-button-redo': 'clickRedo'
    'click #edit-shots-button-clear': 'clickClear'
    'click #edit-shots-button-revert-auto': 'clickRevertShotsAuto'
    'click #edit-shots-button-revert-manual': 'clickRevertShotsManual'
    'click #edit-shots-button-goto-first-unconfirmed': 'clickGotoUnconfirmed'
    'click #edit-shots-button-goto-first-gap': 'clickGotoGap'
    'click #edit-shots-button-confirm-all': 'clickConfirmAll'
    'click #edit-shots-button-unconfirm-all': 'clickUnconfirmAll'
    'click .history-dropdown > button': 'clickHistoryButton'
    'click .button-toggle-icon': 'clickToggleConfirmed'

  initialize: (data) ->
    super(data)

    @videoId = data.videoId
    @video = data.video

    $(window).on('resize', @resize)
    
    @mediator = data.mediator
    @mediator?.subscribe('frameUpdate', @)

    @thumbPath = data.thumbPath
    @thumbPathDigits = data.thumbPathDigits

    @lastFrameNumber = data.lastFrameNumber

    if @videoId
      @loadShots (response) =>
        unless response.success
          console.warn('Shots could not be loaded for this video')

        if @manualShots?.length > 0
          @shots = new ManualShots(@manualShots, @videoId, false)

        else
          @createdFromAuto = true
          @shots = new ManualShots(@autoShots, @videoId, true)

        @setVideoShots()
        @render()

    else
      @render()
    

  getTemplateData: ->
    {
      hasAutoShots: @autoShots?.length > 0
      hasManualShots: @hasManualShots
      createdFromAuto: @createdFromAuto == true
    }
 
  loadShots: (callback) ->
    @elasticShots = new Shots videoId: @videoId
    @elasticShots.fetch
      success: =>
        @autoShots = @elasticShots.getList()
        @manualShots = @elasticShots.getList(false)
        @hasManualShots = @manualShots.length > 0

        callback success: true

      error: ->
        callback success: false

  attach: ->
    super()

    @$container = @$el.find('.edit-shots-container')
    @$countInfo = @$el.find('#shot-edit-count-info')
    @$saveButton = @$el.find('#edit-shots-button-save')
    @$undoButton = @$el.find('#edit-shots-button-undo')
    @$historyButton = @$el.find('#edit-shots-button-undo-history')
    @$history = @$historyButton.next()
    @$redoButton = @$el.find('#edit-shots-button-redo')
    @$infoBox = $('#shot-editor-info-box')
    @$gotoUnconfirmedButton = @$el.find('#edit-shots-button-goto-first-unconfirmed')
    @$gotoGapBUtton = @$el.find('#edit-shots-button-goto-first-gap')
    @$confirmAllButton = @$el.find('#edit-shots-button-confirm-all')
    @$revertManualButton = @$el.find('#edit-shots-button-revert-manual')
    @$unconfirmAllButton = @$el.find('#edit-shots-button-unconfirm-all')

    window.setTimeout(
      =>
        @renderAllShots()
      , 10
    )

    @$historyButton.parent().on('show.bs.dropdown', @beforeShowHistory)

    if @createdFromAuto
      @showInfo(lang._('message.shots_created_from_auto'))

    else
      @showInfo(lang._('message.shots_loaded'))

    @setButtonStates()

  renderAllShots: ->
    @$container.empty()

    if @shots.list.length == 0
      @renderGap({ in: 0, out: 0 }, { in: @lastFrameNumber + 1, out: @lastFrameNumber + 1 })

    else
      if @shots.list[0]?.in > 1
        @renderGap({ in: 0, out: 0 }, @shots.list[0])

      for shot in @shots.list
        if prevShot? and prevShot.out + 1 < shot.in
          @renderGap(prevShot, shot)

        prevShot = shot
        @renderShot(shot)

      if @shots.list[@shots.list.length - 1]?.out < @lastFrameNumber
        @renderGap(@shots.list[@shots.list.length - 1], { in: @lastFrameNumber + 1, out: @lastFrameNumber + 1 })

    @resize()

  resize: =>
    @$container.css('height', '')
    @$container.css('height', $(window).height() - @$container.offset().top - 15)

  # Called by the video mediator
  frameUpdate: (frameNumber) ->
    @setCurrentFrame(frameNumber, true)

  setCurrentFrame: (frameNumber, doScroll = false) ->
    @currentFrame = frameNumber if frameNumber?
    $node = @getNodeByInPoint(@currentFrame)

    @$activeInOut?.removeClass('active')
    delete @$activeInOut

    @$interThumb?.remove()
    delete @$interThumb

    return unless $node?.length == 1

    if parseInt($node.data('in')) == @currentFrame
      @$activeInOut = $node.find('.shot-in')
      @$activeInOut.addClass('active')

    else if parseInt($node.data('out')) == @currentFrame
      @$activeInOut = $node.find('.shot-out')
      @$activeInOut.addClass('active')

    else
      paddedIndex = utils.padStart(@currentFrame, @thumbPathDigits, '0')
      thumbPath = @thumbPath.replace('%s', paddedIndex)
      html = @interThumbTemplate
        thumbPath: thumbPath
        frame: @currentFrame
        canEdit: not $node.hasClass('confirmed')
      $node.append(html)
      @$interThumb = $('#shot-inter-thumb')

    @scrollToNode($node) if doScroll

  scrollToNode: ($node) ->
    return unless $node?.length == 1

    top = $node.position().top
    bottom = top + $node.outerHeight()

    if top < 0 or bottom > @$container.height()
      @$container.scrollTop(top + @$container.scrollTop() - (@$container.height() / 2))
 
  createShotData: (shot) ->
    paddedIndexIn = utils.padStart(shot.in, @thumbPathDigits, '0')
    paddedIndexOut = utils.padStart(shot.out, @thumbPathDigits, '0')

    {
      in: shot.in
      out: shot.out
      thumbIn: @thumbPath.replace('%s', paddedIndexIn)
      thumbOut: @thumbPath.replace('%s', paddedIndexOut)
      type: shot.shotType
      count: shot.out - shot.in + 1
      gap: shot.gap == true
      annotator: shot.annotator
      creationTs: lang.formatDateTime(shot.creationTs)
      valueSource: shot.valueSource
      autoRef: shot.autoRef
      isConfirmed: shot.isConfirmed == true
    }

  addUndo: (message) ->
    @showInfo(message)
    @$undoButton.tooltip('dispose')
    @$redoButton.tooltip('dispose')
    @$undoButton.attr('title', message)
    @$undoButton.tooltip()
    @shots.addUndo(message)

  setButtonStates: ->
    canUndo = @shots.canUndo()
    confirmedCount = @shots.getConfirmedCount()
    gapCount = @$el.find('.edit-shot-item.gap').length

    infoText = lang._s('message.shots_confirmed_info', @shots.getConfirmedCount(), @shots.list.length)
    
    if gapCount > 0
      infoText = "<span class=\"badge badge-danger mr-2 p-1\">#{gapCount} #{lang._('label.gap', gapCount)}</span> #{infoText}"

    @$countInfo.html(infoText)

    @$saveButton.prop('disabled', not canUndo)
    @$undoButton.prop('disabled', not canUndo)
    @$historyButton.prop('disabled', not canUndo)
    @$redoButton.prop('disabled', not @shots.canRedo())
    @$gotoUnconfirmedButton.prop('disabled', confirmedCount >= @shots.list.length)
    @$gotoGapBUtton.prop('disabled', gapCount == 0)
    @$confirmAllButton.prop('disabled', confirmedCount >= @shots.list.length)
    @$unconfirmAllButton.prop('disabled', confirmedCount == 0)
    @$revertManualButton.prop('disabled', not @hasManualShots)

    mediator.publish('application:editing', canUndo)

  setVideoShots: ->
    @video?.shots = @shots.list

  renderGap: (prevShot, shot, $node, replace = true, before = false) ->
    gapShot =
      in: prevShot.out + 1
      out: shot.in - 1
      shotType: 'NA'
      gap: true

    @renderShot(gapShot, $node, replace, before)

  renderShot: (shot, $node, replace = true, before = false) ->
    if shot.gap
      html = @shotTemplate
        shot: @createShotData(shot)

    else
      shotIndex = @shots.getIndexByInPoint(shot.in)
      prevShot = @shots.list[shotIndex - 1] if shotIndex > 0

      html = @shotTemplate
        shot: @createShotData(shot)
        canMoveUp: (not shot.isConfirmed) and prevShot? and (not prevShot.isConfirmed) and prevShot.out > prevShot.in
        canMerge: (not shot.isConfirmed) and prevShot? and (not prevShot.isConfirmed) and prevShot.out == shot.in - 1
        canMoveDown: (not shot.isConfirmed) and prevShot? and (not prevShot.isConfirmed) and shot.out > shot.in

    if $node?
      if replace
        $node.replaceWith(html)

      else if before
        $node.before(html)

      else
        $node.after(html)
    else
      @$container.append(html)

  createShotFromEvent: (event) ->
    $node = @getNodeForElement($(event.currentTarget))

    {
      in: parseInt($node.data('in'))
      out: parseInt($node.data('out'))
      shotType: $node.data('type') or null
    }

  getNodeByInPoint: (inPoint) ->
    if @shots.list.length == 0 or @shots.list[0].in > inPoint
      $node = @$container.find('.edit-shot-item.gap:first-child')

    else if @shots.list[@shots.list.length - 1].out < inPoint
      $node = @$container.find('.edit-shot-item.gap:last-child')

    else
      shot = @shots.getShotByInPoint(inPoint)
      $node = $("#edit-shot-item-#{shot.in}")

      if shot.out < inPoint
        $node = $node.next('.gap')

    $node

  showInfo: (message, type = 'info') ->
    if type in [ 'undo', 'redo' ]
      alertType = 'info'
      badge = "<span class=\"badge badge-info\">#{type.toUpperCase()}</span> "

    else
      alertType = type
      badge = ''

    @$infoBox.html("<div class=\"alert alert-#{alertType} mb-0\">#{badge}#{message}</div>")

  getNodeForElement: ($element) ->
    $element.closest('.edit-shot-item')

  showChangeShotTypeModal: (value, callback) ->
    content = @changeShotTypeTemplate
      value: value
      shotTypes: @shotTypes

    new ModalView
      header: lang._('button.change_shot_type')
      content: content
      confirmText: lang._('button.change_shot_type')
      parent: @
      callback: ($modal) =>
        callback?($modal.find('select').val())
        true

  beforeShowHistory: =>
    @$history.empty()

    for item, index in @shots.undoList
      @$history.prepend("<button type=\"button\" class=\"dropdown-item\" data-index=\"#{index}\"><span class=\"badge badge-info\">#{index + 1}</span> #{item.message}</button>")

  clickShotThumb: (event) ->
    @mediator.setFrame(event.currentTarget.dataset.frame)

  clickCreateShotFromGap: (event) ->
    shot = @createShotFromEvent(event)
    @addUndo(lang._s('message.shot_created_from_gap', shot.in, shot.out))
    @shots.addShot(shot)
    $node = @getNodeForElement($(event.currentTarget))
    $nextNode = $node.next()
    @renderShot(shot, $node)
    nextShot = @shots.getNextShotByInPoint(shot.in)

    if nextShot?
      @renderShot(nextShot, $nextNode)

    @setCurrentFrame()
    @setVideoShots()
    @setButtonStates()

  clickSplitShotBefore: (event) ->
    return unless @currentFrame?

    $node = @getNodeForElement($(event.currentTarget))

    if $node.hasClass('gap')
      inPoint = parseInt($node.data('in'))
      outPoint = parseInt($node.data('out'))

      @addUndo(lang._s('message.shot_created_from_gap', inPoint, @currentFrame - 1))

      addedShot = @shots.addShot
        in: inPoint
        out: @currentFrame - 1
        shotType: 'NA'

      @renderShot(addedShot, $node, false, true)
      @renderGap(addedShot, { in: outPoint + 1, out: outPoint + 1 }, $node)

    else
      shot = @shots.getShotByInPoint($node.data('in'))

      return unless @currentFrame > shot.in and @currentFrame <= shot.out

      @addUndo(lang._s('message.shot_splitted', @currentFrame - 1, @currentFrame))

      inPoint = shot.in
      shot.in = @currentFrame

      @shots.removeAutoRef(shot)

      addedShot = @shots.addShot
        in: inPoint
        out: @currentFrame - 1
        shotType: shot.shotType

      @renderShot(addedShot, $node, false, true)
      @renderShot(shot, $node)

    @setButtonStates()
    @setVideoShots()
    @setCurrentFrame()

  clickSplitShotAfter: (event) ->
    return unless @currentFrame?

    $node = @getNodeForElement($(event.currentTarget))

    if $node.hasClass('gap')
      inPoint = parseInt($node.data('in'))
      outPoint = parseInt($node.data('out'))

      @addUndo(lang._s('message.shot_created_from_gap', @currentFrame + 1, outPoint))

      addedShot = @shots.addShot
        in: @currentFrame + 1
        out: outPoint
        shotType: 'NA'

      @renderShot(addedShot, $node, false, false)
      @renderGap({ in: inPoint - 1, out: inPoint - 1 }, addedShot, $node)
      @setButtonStates()

    else
      shot = @shots.getShotByInPoint($node.data('in'))

      return unless @currentFrame > shot.in and @currentFrame <= shot.out

      @addUndo(lang._s('message.shot_splitted', @currentFrame, @currentFrame + 1))

      outPoint = shot.out
      shot.out = @currentFrame

      @shots.removeAutoRef(shot)

      addedShot = @shots.addShot
        in: @currentFrame + 1
        out: outPoint
        shotType: shot.shotType

      @renderShot(addedShot, $node, false, false)
      @renderShot(shot, $node)

    @setButtonStates()
    @setVideoShots()
    @setCurrentFrame()

  clickMergeShots: (event) ->
    inPoint = event.currentTarget.dataset.in
    shotIndex = @shots.getIndexByInPoint(inPoint)
    shot = @shots.getShotByInPoint(inPoint)
    prevShot = @shots.getPrevShotByInPoint(inPoint)

    @addUndo(lang._s('message.shots_merged', prevShot.in, shot.out))

    shot.in = prevShot.in
    @shots.removeShotByIndex(shotIndex - 1)

    @shots.removeAutoRef(shot)

    $node = @getNodeForElement($(event.currentTarget))
    $node.prev().remove()
    @renderShot(shot, $node)

    @setButtonStates()
    @setCurrentFrame()

  clickMoveUp: (event) ->
    $node = @getNodeForElement($(event.currentTarget))
    inPoint = $node.data('in')
    shot = @shots.getShotByInPoint(inPoint)
    prevShot = @shots.getPrevShotByInPoint(inPoint)

    $prevNode = $node.prev()
    
    @addUndo(lang._s('message.shots_moved_up', prevShot.out - 1, shot.in - 1))
    shot.in--
    prevShot.out--

    @shots.removeAutoRef(shot)
    @shots.removeAutoRef(prevShot)

    $nextNode = $node.next()

    @renderShot(shot, $node)
    @renderShot(prevShot, $prevNode)

    if $nextNode.length == 1 and not $nextNode.hasClass('gap')
      nextShot = @shots.getShotByInPoint($nextNode.data('in'))
      @renderShot(nextShot, $nextNode)

    @setButtonStates()
    @setVideoShots()
    @setCurrentFrame()
    
  clickMoveDown: (event) ->
    $node = @getNodeForElement($(event.currentTarget))
    inPoint = $node.data('in')
    shot = @shots.getShotByInPoint(inPoint)
    prevShot = @shots.getPrevShotByInPoint(inPoint)
    $prevNode = $node.prev()

    @addUndo(lang._s('message.shots_moved_down', prevShot.out + 1, shot.in + 1))
    shot.in++
    prevShot.out++

    @shots.removeAutoRef(shot)
    @shots.removeAutoRef(prevShot)

    $nextNode = $node.next()

    @renderShot(shot, $node)
    @renderShot(prevShot, $prevNode)

    if $nextNode.length == 1 and not $nextNode.hasClass('gap')
      nextShot = @shots.getShotByInPoint($nextNode.data('in'))
      @renderShot(nextShot, $nextNode)

    @setButtonStates()
    @setCurrentFrame()
  
  clickChangeShotType: (event) ->
    $node = @getNodeForElement($(event.currentTarget))
    inPoint = $node.data('in')
    shot = @shots.getShotByInPoint(inPoint)

    @showChangeShotTypeModal shot.shotType, (shotType) =>
      return if shot.shotType == shotType

      @addUndo(lang._s('message.shots_changed_type', shot.shotType, shotType, shot.in, shot.out))
      shot.shotType = shotType

      @shots.removeAutoRef(shot)
      
      @setButtonStates()
      @renderShot(shot, $node)

  clickDeleteShot: (event) ->
    $node = @getNodeForElement($(event.currentTarget))

    $prevNode = $node.prev()
    $nextNode = $node.next()

    inPoint = parseInt($node.data('in'))
    outPoint = parseInt($node.data('out'))

    @addUndo(lang._s('message.shots_deleted_shot', inPoint, outPoint))

    if $prevNode.hasClass('gap')
      inPoint = parseInt($prevNode.data('in'))
      $prevNode.remove()

    if $nextNode.hasClass('gap')
      outPoint = parseInt($nextNode.data('out'))
      $nextNode.remove()

    @shots.removeShotByIndex(@shots.getIndexByInPoint(inPoint))
    @renderGap({in: inPoint - 1, out: inPoint - 1}, {in: outPoint + 1, out: outPoint + 1}, $node)
    @setButtonStates()
    @setVideoShots()
    @setCurrentFrame()

  clickToggleConfirmed: (event) ->
    $node = @getNodeForElement($(event.currentTarget))

    inPoint = parseInt($node.data('in'))
    outPoint = parseInt($node.data('out'))

    shot = @shots.getShotByInPoint(inPoint)

    isConfirmed = not (shot.isConfirmed == true)

    if isConfirmed
      messageKey = 'message.shot_confirmed'

    else
      messageKey = 'message.shot_unconfirmed'

    @addUndo(lang._s(messageKey, inPoint, outPoint))

    shot.isConfirmed = isConfirmed

    $nextNode = $node.next()
    nextShot = @shots.getNextShotByInPoint(shot.in)

    if nextShot?
      @renderShot(nextShot, $nextNode)

    @renderShot(shot, $node)
    @setButtonStates()
    @setCurrentFrame()

  clickSave: ->
    @addSpinner(@$el)
    @shots.save (response) =>
      @removeSpinner(@$el)

      if response.success
        scrollTop = @$container.scrollTop()
        @hasManualShots = true
        @shots.clearUndo()
        @setButtonStates()
        @$undoButton.tooltip('dispose')
        @$redoButton.tooltip('dispose')
        @renderAllShots()
        @setVideoShots()
        @setCurrentFrame()
        @$container.scrollTop(scrollTop)
        @showInfo(lang._('message.shots_saved'), 'success')

      else
        @showInfo(lang._('message.shots_save_error'), 'danger')

  clickUndo: (event, undoIndex) ->
    scrollTop = @$container.scrollTop()
    message = @shots.undo(undoIndex)

    @showInfo(message, 'undo')
    @renderAllShots()
    
    @$undoButton.tooltip('dispose')
    @setButtonStates()
    @$redoButton.tooltip('dispose')
    
    message = @shots.getUndoMessage()
    redoMessage = @shots.getRedoMessage()
    
    @$undoButton.attr('title', message)
    @$undoButton.tooltip() if message?

    @$redoButton.attr('title', redoMessage)
    @$redoButton.tooltip() if redoMessage?

    @$container.scrollTop(scrollTop)
    @setVideoShots()
    @setCurrentFrame(null)

  clickRedo: ->
    scrollTop = @$container.scrollTop()
    message = @shots.redo()

    @showInfo(message, 'redo')
    @renderAllShots()

    @$undoButton.tooltip('dispose')
    @setButtonStates()
    @$redoButton.tooltip('dispose')

    message = @shots.getUndoMessage()
    redoMessage = @shots.getRedoMessage()
    
    @$undoButton.attr('title', message)
    @$undoButton.tooltip() if message?

    @$redoButton.attr('title', redoMessage)
    @$redoButton.tooltip() if redoMessage?

    @$container.scrollTop(scrollTop)
    @setVideoShots()
    @setCurrentFrame(null)

  clickClear: ->
    new ModalView
      header: lang._('button.clear_shots')
      content: lang._('message.confirm_clear_shots')
      confirmText: lang._('button.clear_shots')
      parent: @
      callback: =>
        @shots = new ManualShots([], @videoId, true)
        @showInfo(lang._('message.shots_cleared'))
        @setButtonStates()
        @$undoButton.tooltip('dispose')
        @$redoButton.tooltip('dispose')
        @renderAllShots()
        @setVideoShots()
        @setCurrentFrame()
        true    

  clickRevertShotsAuto: ->
    new ModalView
      header: lang._('button.revert_shots_to_auto')
      content: lang._('message.revert_shots_to_auto')
      confirmText: lang._('button.revert_shots_to_auto')
      parent: @
      callback: =>
        @loadShots (response) =>
          if response.success
            @shots = new ManualShots(@autoShots, @videoId, true)
            @showInfo(lang._('message.shots_reverted_to_auto'))
            @$undoButton.tooltip('dispose')
            @$redoButton.tooltip('dispose')
            @renderAllShots()
            @setButtonStates()
            @setVideoShots()
            @setCurrentFrame()
        
        true

  clickRevertShotsManual: ->
    new ModalView
      header: lang._('button.revert_shots_to_manual')
      content: lang._('message.revert_shots_to_manual')
      confirmText: lang._('button.revert_shots_to_manual')
      parent: @
      callback: =>
        @loadShots (response) =>
          if response.success
            @shots = new ManualShots(@manualShots, @videoId, true)
            @showInfo(lang._('message.shots_reverted_to_manual'))
            @$undoButton.tooltip('dispose')
            @$redoButton.tooltip('dispose')
            @renderAllShots()
            @setButtonStates()
            @setVideoShots()
            @setCurrentFrame()
        
        true

  clickGotoGap: ->
    $gap = @$container.find('.edit-shot-item.gap:first')
    return if $gap.length != 1

    @scrollToNode($gap)

  clickGotoUnconfirmed: ->
    $unconfirmed = @$container.find('.edit-shot-item:not(.confirmed):first')
    return if $unconfirmed.length != 1

    @scrollToNode($unconfirmed)

  clickConfirmAll: ->
    scrollTop = @$container.scrollTop()
    @addUndo(lang._('message.confirm_all_shots'))
    @shots.confirmAll()
    @renderAllShots()
    @$container.scrollTop(scrollTop)
    @setButtonStates()
    @setVideoShots()
    @setCurrentFrame()

  clickUnconfirmAll: ->
    scrollTop = @$container.scrollTop()
    @addUndo(lang._('message.unconfirm_all_shots'))
    @shots.unconfirmAll()
    @renderAllShots()
    @$container.scrollTop(scrollTop)
    @setButtonStates()
    @setVideoShots()
    @setCurrentFrame()
  
  remove: ->
    @$undoButton.tooltip('dispose')
    @$redoButton.tooltip('dispose')
    super()

  clickHistoryButton: (event) ->
    undoIndex = event.currentTarget.dataset.index
    @clickUndo(event, undoIndex)

  
