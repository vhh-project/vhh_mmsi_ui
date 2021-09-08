Model       = require './base/model'
CaBaseModel = require './ca-base-model'

module.exports = class CaObject extends CaBaseModel
  objectType        : 'ca_objects'
  labelKey          : 'label.object'
  additionalFetched : false

  fetchAdditional: (callback) ->
    model = new Model
    
    item = @getPrimaryRepresentation()
    
    unless item?.urls?.original? and item.info?.original?
      additionalFetched = true
      callback({success: false})
      return

    filename = @getFilename(item.urls.original)

    unless filename?
      additionalFetched = true
      callback({success: false})
      return

    unless @hasVideo()
      additionalFetched = true
      callback({success: true})
      return

    model.url = "#{window.settings.videoUrlBase}media/mmsi/videos/#{item.representation_id}/frames/json/thumb_#{filename}.json"
    model.fetch
      success: (response) =>
        @additionalData = model.attributes
        @additionalFetched = true
        callback(success: true)

      error: (response) =>
        @additionalFetched = true
        callback({success: false})

  getFilename: (path) ->
    return unless path?.length > 0 and path.indexOf('/') > -1
    path.substr(path.lastIndexOf('/') + 1)

  getFps: ->
    if @additionalData?.fps_real?
      @additionalData.fps_real

    else
      item = @getPrimaryRepresentation()
      fps = item.info.original.PROPERTIES.framerate
    
      if fps? then Number(fps) else 24

  getFrameLength: ->
    @additionalData?.frames or null

  getPrimaryVideoData: ->
    item = @getPrimaryRepresentation()
    return null unless item?.urls?.original? and item.info?.original?

    filename = @getFilename(item.urls.original)
    thumbPath = "#{window.settings.videoUrlBase}media/mmsi/videos/#{item.representation_id}/frames/"

    {
      id: item.representation_id
      url: @updateUrl(item.urls.original)
      posterframe: @updateUrl(item.urls.preview170)
      jsonFile: "#{thumbPath}json/thumb_#{filename}.json"
      thumbPath: thumbPath
      thumbPattern: "#{thumbPath}thumb_#{filename}_%s.jpg"
      thumbDigits: 9      
      mimeType: item.mimetype
      fps: @getFps()
      frames: @getFrameLength()
    }

  getIdFromReponse: (response) ->
    response.object_id or null

  getOverscanMask: ->
    maskSettings = @get('vhh_OverscanMask')
    return null unless maskSettings?.length > 0

    maskSettings = maskSettings[0]

    top = parseFloat(maskSettings.OM_top.data)
    bottom = parseFloat(maskSettings.OM_bottom.data)
    left = parseFloat(maskSettings.OM_left.data)
    right = parseFloat(maskSettings.OM_right.data)

    return null unless top? and bottom? and left? and right?
    return null unless top > 0 or bottom > 0 or left > 0 or right > 0
    return null unless top < 0.5 and bottom > 0.5 and left < 0.5 and right > 0.5

    {
      top: top
      bottom: 1 - bottom
      left: left
      right: 1 - right
    }

  getParentId: ->
    related = @get('related')?.ca_objects
    return null unless @subType in ['item', 'av_manifestation', 'nonav_manifestation'] and related?

    for item in related
      if @subType == 'item' and item.relationship_type_code in ['isitemofav', 'isitemofnonav']
        return item.object_id

      else if @subType == 'nonav_manifestation' and item.relationship_type_code == 'ismanifestationofnonav'
        return item.object_id

      else if @subType == 'av_manifestation' and item.relationship_type_code == 'ismanifestationofav'
        return item.object_id

    return null

  getChildrenIds: ->
    related = @get('related')?.ca_objects

    return [] unless @subType in ['av_creation', 'nonav_creation', 'av_manifestation', 'nonav_manifestation'] and related?

    idList = []

    for item in related
      if @subType == 'av_creation' and item.relationship_type_code == 'ismanifestationofav'
        idList.push(item.object_id)

      else if @subType == 'nonav_creation' and item.relationship_type_code == 'ismanifestationofnonav'
        idList.push(item.object_id)

      else if @subType == 'av_manifestation' and item.relationship_type_code == 'isitemofav'
        idList.push(item.object_id)

      else if @subType == 'nonav_manifestation' and item.relationship_type_code == 'isitemofnonav'
        idList.push(item.object_id)
        
    idList

  hasVideo: ->
    representation = @getPrimaryRepresentation()
    representation?.mimetype in ['video/mpeg', 'video/mp4', 'video/ogg', 'video/quicktime']





  
  







