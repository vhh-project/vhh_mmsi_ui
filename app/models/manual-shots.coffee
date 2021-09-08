Model = require 'models/base/model'

module.exports = class ManualShots
  MAX_UNDO_ENTRIES: 5000

  constructor: (shotList, videoId, isAuto) ->
    @videoId = videoId

    @list = []
    @undoList = []
    @redoList = []

    for item in shotList
      @list.push
        in: item.in
        out: item.out
        shotType: item.shotType
        annotator: item.annotator
        creationTs: item.creationTs
        valueSource: item.valueSource
        status: 'M'
        autoRef: if isAuto then item.id else item.autoRef
        isConfirmed: item.isConfirmed

    @list.sort (a, b) ->
      if a.in > b.in then 1 else -1

  getIndexByInPoint: (inPoint) ->
    inPoint = parseInt(inPoint)

    return null if isNaN(inPoint) or inPoint < 1
    return -1 if @list.length == 0 or @list[0].in > inPoint

    for item, index in @list
      if item.in > inPoint
        return index - 1

    lastItem = @list[@list.length - 1]
    
    if lastItem.out >= inPoint
      @list.length - 1

    else
      @list.length

  getShotByInPoint: (inPoint) ->
    index = @getIndexByInPoint(inPoint)
    return null if index < 0 or index >= @list.length
    @list[index]

  getPrevShotByInPoint: (inPoint) ->
    index = @getIndexByInPoint(inPoint)
    return null if index <= 0 or @list.length < 1
    @list[index - 1]

  getNextShotByInPoint: (inPoint) ->
    index = @getIndexByInPoint(inPoint)
    return null if index < 0 or index + 1>= @list.length
    @list[index + 1]

  removeShotByIndex: (index) ->
    return unless index >= 0 and @list.length - 1 >= index
    @list.splice(index, 1)

  getConfirmedCount: ->
    count = 0
    
    for item in @list
      count++ if item.isConfirmed == true

    count

  addShot: (shot) ->
    return unless shot? and shot.in? and shot.out?
    return if shot.in > shot.out

    date = new Date

    shotToAdd =
      in: parseInt(shot.in)
      out: parseInt(shot.out)
      shotType: shot.shotType or 'NA'
      annotator: window.bootstrap.userMe.get('username')
      creationTs: date.toISOString()
      valueSource: 'VHH_MMSI_shot_editor'
      status: 'M'
      autoRef: null

    if @list.length == 0
      @list.push(shotToAdd)
      return shotToAdd

    index = @getIndexByInPoint(shotToAdd.in)
    
    if index == -1
      @list.unshift(shotToAdd)

    else if index == @list.length
      @list.push(shotToAdd)

    else
      @list.splice(index + 1, 0, shotToAdd)

    shotToAdd

  removeAutoRef: (shot) ->
    return unless shot.autoRef?

    date = new Date

    shot.annotator = window.bootstrap.userMe.get('username')
    shot.autoRef = null
    shot.creationTs = date.toISOString()
    shot.valueSource = 'VHH_MMSI_shot_editor'

  confirmAll: (isConfirmed = true) ->
    for item in @list
      item.isConfirmed = isConfirmed

  unconfirmAll: ->
    @confirmAll(false)

  addUndo: (message, clearRedo = true) ->
    if @undoList.length >= @MAX_UNDO_ENTRIES
      @undoList.splice(0, @undoList.length - @MAX_UNDO_ENTRIES + 1)

    list = _.map @list, (item) ->
      _.clone item

    @redoList = [] if clearRedo

    @undoList.push
      message: message
      list: list

  clearUndo: ->
    @undoList = []
    @redoList = []

  addRedo: (message, list) ->
    list = @list unless list?
    list = _.map list, (item) ->
      _.clone item

    @redoList.push
      message: message
      list: list

  getUndoMessage: ->
    return null unless @undoList.length > 0
    @undoList[@undoList.length - 1].message

  getRedoMessage: ->
    return null unless @redoList.length > 0
    @redoList[@redoList.length - 1].message

  undo: (undoIndex) ->
    return unless @undoList.length > 0

    if undoIndex?
      return if undoIndex >= @undoList.length

      list = @undoList.splice(undoIndex, @undoList.length - undoIndex)
      prevList = @list

      for index in [ list.length - 1 .. 0 ]
        item = list[index]
        @addRedo(item.message, prevList)
        prevlist = item.list

      undoItem = list[0]
      @list = undoItem.list
      undoItem.message

    else
      item = @undoList.pop()
      @addRedo(item.message)
      @list = item.list
      item.message

  redo: ->
    return unless @redoList.length > 0

    item = @redoList.pop()
    @addUndo(item.message, false)
    @list = item.list
    item.message

  canUndo: ->
    @undoList.length > 0

  canRedo: ->
    @redoList.length > 0

  save: (callback) ->
    deleteQuery =
      query:
        bool:
          must: [
            {
              term: 
                video_id: @videoId
            }
            {
              term: 
                status: 'M'
            }
          ]

    $.ajax
      type: 'POST'
      url: "#{window.settings.tbaUrl}_delete_by_query"
      cache: true
      beforeSend: (xhr) ->
        token = Model.getXSRFCookie()
        xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?
      contentType: 'application/json'
      dataType: 'json'
      data: JSON.stringify(deleteQuery)
        
      success: (response) =>
        bulkData = []
        
        for item in @list
          bulkData.push(index: {})
          bulkData.push
            video_id: @videoId
            in_point: item.in
            out_point: item.out
            annotator: item.annotator
            status: 'M'
            class_name: 'shot'
            value: item.shotType
            value_source: item.valueSource
            creation_ts: item.creationTs
            ref_to_auto: item.autoRef
            is_confirmed: item.isConfirmed == true

        bulkData = _.map bulkData, (item) ->
          JSON.stringify(item)

        $.ajax
          type: 'POST'
          url: "#{window.settings.tbaUrl}_bulk"
          cache: true
          beforeSend: (xhr) ->
            token = Model.getXSRFCookie()
            xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?
          contentType: 'application/json'
          dataType: 'json'
          data: bulkData.join("\n") + "\n"
          success: (response) ->
            @undoList = []
            @redoList = []
            callback(success: true)

          error: ->
            callback(success: false)

      error: ->
        callback(success: false)










  

