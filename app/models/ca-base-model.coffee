Model             = require './base/model'
ObjectDefinitions = require './object-definitions'

module.exports = class CaBaseModel extends Model
  # CA type:
  # - ca_objects
  # - ca_entities
  # - ca_places
  # - ca_events
  # - ca_collections
  objectType: 'ca_objects'

  # CA subtype:
  # - av_creation (ca_objects)
  # - nonav_creation (ca_objects)
  # - av_manifestation (ca_objects)
  # - nonav_manifestation (ca_objects)
  # - item (ca_objects)
  # - person (ca_entities)
  # - group (ca_entities)
  # - corporate (ca_entities)
  # - other (ca_places)
  # - city (ca_places)
  # - continent (ca_places)
  # - country (ca_places)
  # - county (ca_places)
  # - location (ca_places)
  # - state (ca_places)
  # - river (ca_places)
  # - neighborhood (ca_places)
  # - petoria (ca_places)
  # - event_award (ca_occurrences)
  # - event_decision (ca_occurrences)
  # - event (ca_occurrences)
  # - event_ipr (ca_occurrences)
  # - event_preservation (ca_occurrences)
  # - event_production (ca_occurrences)
  # - event_publication (ca_occurrences)
  subType: null

  # Used for getting pretty JSON data from Collective Access
  prettyJSON: true

  # Language key to a pluralized version of the name ("object|objects")
  labelKey: null

  # Additional attributes to be loaded for specific relations
  relationAttrs: [
    'ca_occurrences.vhh_DateEvent'
  ]

  urlRoot: ->
    "#{window.settings.apiUrl}ca/service/item/#{@objectType}"

  url: ->
    url = @urlRoot()
    url += "/id/#{@id}" if @id?
    url += '?format=edit'
    url += "&add_relation_info=#{@relationAttrs.join(';')}" if @relationAttrs?.length > 0
    url += "&showdisplaytext=1" if @id?
    url += '&forceidno=1' unless @id?
    url += '&pretty=1' if @prettyJSON == true
    url

  loadCaDefinition: (callback) ->
    ObjectDefinitions.loadCaDefinition(@objectType, callback)

  getObjectGroup: ->
    ObjectDefinitions.getObjectGroup(@objectType)

  getObjectType: ->
    typeId = @getTypeId()
    return null unless typeId?
    ObjectDefinitions.getObjectTypeById(typeId)

  getObjectTypeLabel: ->
    ObjectDefinitions.getObjectTypeLabel(@getTypeId())

  getPreferredLabel: ->
    preferredLabels = @get('preferred_labels')?[0]
    objectType = @getObjectType()
    return '' unless preferredLabels? and objectType?.preferredLabelKeys?

    labels = _.map objectType.preferredLabelKeys, (key) ->
      preferredLabels[key] or ''

    labels.join('')

  createAttrGroupsForDetails: (groupIndex) ->
    objectGroups = @getObjectType()
    return null unless objectGroups?.groups?[groupIndex]?.attrGroups?

    ObjectDefinitions.createAttrGroups(objectGroups.groups[groupIndex].attrGroups, @objectType)

  createAttrGroupsForCreation: ->
    objectGroups = @getObjectType()
    return null unless objectGroups?.createAttrs?

    ObjectDefinitions.createAttrGroups(objectGroups.createAttrs, @objectType)

  createAttrGroupsForSummaries: ->
    objectGroups = @getObjectType()
    return null unless objectGroups?.summaries?

    _.map objectGroups.summaries, (summary) ->
      list = _.map summary.attrs, (attr) -> if typeof attr == 'string' then attr else attr.key
      definitions = ObjectDefinitions.createAttrGroups(list, @objectType)
      
      {
        label: lang._(summary.label)
        showThumbnail: summary.showThumbnail == true
        definitions: definitions
        attrs: summary.attrs
      }

  getTypeId: ->
    @get('intrinsic_fields.type_id')

  saveAttributes: (data, callback) ->
    updateData = {}

    if data.update?
      updateData.update_attributes = {} unless updateData.update_attributes?

      for key, object of data.update
        updateData.update_attributes[key] = object

    if data.new?
      updateData.attributes = {} unless updateData.attributes?
      
      for key, object of data.new
        updateData.attributes[key] = [] unless updateData.attributes[key]?
        updateData.attributes[key].push(object)

    if data.intrinsic_fields?
      updateData.intrinsic_fields = data.intrinsic_fields

    if data.preferred_labels?
      updateData.preferred_labels = data.preferred_labels
      updateData.remove_all_labels = true if @id?

    if data.remove_attributes_by_id?
      updateData.remove_attributes_by_id = data.remove_attributes_by_id

    @saveData(updateData, callback)

  saveRelations: (data, callback) ->
    updateData = {}

    if data.new?
      updateData.related = {}

      for key, object of data.new
        updateData.related[key] = [] unless updateData.related[key]?
        updateData.related[key] = updateData.related[key].concat(object)

    @saveData(updateData, callback)
    
  saveData: (updateData, callback) ->
    $.ajax
      type: 'PUT'
      url: @url()
      dataType: 'json'
      contentType: 'application/json'
      data: JSON.stringify(updateData)
      beforeSend: (xhr) ->
        token = Model.getXSRFCookie()
        xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?

      success: (response) =>
        if response.ok == true
          callback
            success: true
            id: @getIdFromReponse(response)

        else
          if response.errors?
            callback
              success: false
              errors: response.errors

          else
            callback
              success: false

      error: ->
        callback
          success: false

  deleteAttribute: (attrKey, index, callback) ->
    modelAttrs = @get(attrKey)

    unless modelAttrs?[index]?._id?
      callback
        success: false

      return

    data =
      remove_attributes_by_id: [ modelAttrs[index]._id ]

    @saveAttributes data, (response) =>
      if response.success
        modelAttrs.splice(index, 1)

      callback(response)

  deletePreferredLabel: (index, callback) ->
    labels = @get('preferred_labels')
    labels.splice(index, 1)
    @saveAttributes { preferred_labels: labels }, callback

  updateRelation: (typeKey, idKey, index, typeId, reverse, callback) ->
    relation = @get('related')?[typeKey]?[index]

    unless relation?
      callback
        success: false

      return

    data =
      update_relationship_types:
        "#{typeKey}": [{
          relation_id: relation.relation_id
          rel_id: relation[idKey]
          type_id: typeId
          direction: if reverse then 'rtol' else 'ltor'
        }]

    @saveData data, (response) =>
      if response.success
        relation.type_id = typeId
        relationshipTypes = @getRelationshipTypes(typeKey)

        newType = _.find relationshipTypes, (item) ->
          item.type_id == typeId

        if newType?
          if reverse
            relation.direction = 'rtol'
            relation.relationship_typename = newType.typename_reverse

          else
            relation.direction = 'ltor'
            relation.relationship_typename = newType.typename

      callback(response)

  deleteRelation: (typeKey, index, callback) ->
    relation = @get('related')?[typeKey]?[index]

    unless relation?
      callback
        success: false

      return
    
    data =
      remove_relationships_by_id:
        "#{typeKey}": [ relation.relation_id ]

    @saveData data, (response) =>
      if response.success
        @get('related')[typeKey].splice(index, 1)

      callback(response)

  saveInterstitial: (typeKey, index, attrKey, id, data, callback) ->
    relation = @get('related')?[typeKey]?[index]

    unless relation?
      callback
        success: false

      return

    if id?
      requestType = 'update_interstitial'
      data._id = id

    else
      requestType = 'add_interstitial'

    updateData =
      "#{requestType}":
        "#{typeKey}": [{
          relation_id: relation.relation_id
          attrs: {
            "#{attrKey}": [ data ]
          }
        }]
    
    @saveData(updateData, callback)

  deleteInterstitial: (typeKey, index, attrKey, attrIndex, callback) ->
    relation = @get('related')?[typeKey]?[index]
    interstitial = relation?.attributes?[attrKey]?[attrIndex]

    unless interstitial?
      callback
        success: false

      return

    data =
      delete_interstitial:
        "#{typeKey}": [{
          relation_id: relation.relation_id
          interstitial_id: interstitial._id
        }]

    @saveData data, (response) =>
      if response.success
        relation.attributes[attrKey].splice(attrIndex, 1)

      callback(response)

  deleteRecord: (callback) ->
    $.ajax
      url: @url()
      type: 'DELETE'
      dataType: 'json'
      beforeSend: (xhr) ->
        token = Model.getXSRFCookie()
        xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?

      success: (response) =>
        callback
          success: true

      error: ->
        callback
          success: false

  parse: (data) ->
    return {} unless data?
    return {} if data.ok? and data.ok != true

    data.attributes = {} unless data.attributes?

    data.attributes.intrinsic_fields = data.intrinsic_fields or {}
    data.attributes.preferred_labels = data.preferred_labels or {}
    data.attributes.related = data.related or {}
    data.attributes.representations = data.representations or {}

    @subType = ObjectDefinitions.getSubTypeById(data.intrinsic_fields.type_id)

    data.attributes

  validate: ($form, definition) ->
    data = {}
    error = false

    $form.find('.form-control:not(.label-only)').each (nodeIndex, node) =>
      $node = $(node)
      $col = $node.closest('.edit-form-col')
      errorText = null
      index = $node.data('index')
      attrKey = $node.data('attr-key')
      key = $node.data('key')

      if key == '_value_source'
        value = $.trim($node.val())

      else
        item = definition.items[$col.data('value-index')]

        switch item.type
          when 'vocabulary'
            value = $node.val()

          else
            value = $.trim($node.val())

        # Actual validation
        if item.required == true and value.length == 0
          errorText = 'form.required'

      if errorText?
        $col.append("<div class=\"invalid-feedback\">#{lang._(errorText)}</div>")
        $node.addClass('is-invalid')
        error = true

      else
        $node.removeClass('is-invalid')

        switch attrKey
          when 'intrinsic_fields'
            data.intrinsic_fields = {} unless data.intrinsic_fields?
            data.intrinsic_fields[key] = value

          when 'preferred_labels'
            unless index? and index.toString().length > 0
              index = 0

            unless data.preferred_labels?
              if @has('preferred_labels')
                data.preferred_labels = @get('preferred_labels')

              else
                data.preferred_labels = []

            unless data.preferred_labels[index]?
              data.preferred_labels[index] = {}
            
            data.preferred_labels[index][key] = value

          else
            if index.length == 0
              data.new = {} unless data.new?
              data.new[attrKey] = {} unless data.new[attrKey]?
              data.new[attrKey][key] = value
              
            else
              data.update = {} unless data.update?
              data.update[attrKey] = [] unless data.update[attrKey]?

              attrs = @get(attrKey)
              idToFind = attrs[index]._id
              object = _.find data.update[attrKey], (attr) -> attr._id == idToFind

              unless object?
                object = _.find attrs, (attr) -> attr._id == idToFind
                data.update[attrKey].push(object)

              object[key] = value

    if error == true
      return null

    else
      return data

  getIdFromReponse: ->
    null

  getRelationshipTypes: (otherTypeKey) ->
    types = ObjectDefinitions.getRelationshipTypes(@getTypeId(), otherTypeKey)
    return {} unless types?
    
    idList = {}

    for key, type of types
      idList[type.type_id] = type.parent_id

    for key, type of types
      searchId = type.parent_id
      depth = 1
      idHistory = []

      while _.has(idList, searchId) and searchId not in idHistory
        depth++
        idHistory.push(searchId)
        searchId = idList[searchId]

      type.depth = depth

    result = _.filter types, (type, key) ->
      type.key = key
      type.depth == 1

    result = _.sortBy result, (item) -> item.typename?.toLowerCase()

    depth = 2
    done = false

    while depth < 5 and not done
      depthList = _.filter types, (type) ->
        type.depth == depth

      depthList = _.sortBy(
        depthList,
        (item) ->
          item.typename?.toLowerCase()
        , 'desc'
      ).reverse()

      for depthItem in depthList
        for resultItem, index in result
          if resultItem.type_id == depthItem.parent_id
            result.splice(index + 1, 0, depthItem)
            continue
      if depthList.length == 0
        done = true

      depth++

    result

  getAllowedRelationTypeIds: (otherTypeKey, otherTypeId) ->
    typeId = @getTypeId()
    relationshipTypes = @getRelationshipTypes(otherTypeKey)
    return [] unless relationshipTypes?

    result = []

    for key, type of relationshipTypes
      leftTypeId = type.sub_type_left_id or ''
      rightTypeId = type.sub_type_right_id or ''

      if leftTypeId.length == 0 and rightTypeId.length == 0
        result.push(type.type_id)

      else if leftTypeId.length == 0 and rightTypeId in [typeId, otherTypeId]
        result.push(type.type_id)

      else if rightTypeId.length == 0 and leftTypeId in [typeId, otherTypeId]
        result.push(type.type_id)

      else if (leftTypeId == typeId and rightTypeId == otherTypeId) or (leftTypeId == otherTypeId and rightTypeId == typeId)
        result.push(type.type_id)

    result

  uploadThumb: (file, callback) ->
    formData = new FormData

    filename = ''

    for i in [0 .. file.name.length - 1]
      code = file.name.charCodeAt i
      filename += String.fromCharCode(code) if code < 256

    formData.append('thumb', file, filename)

    $.ajax
      url: "#{@url()}&uploadthumb=1"
      type: 'POST'
      dataType: 'json'
      contentType: false
      processData: false
      cache: false
      data: formData
      beforeSend: (xhr) ->
        token = Model.getXSRFCookie()
        xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?
      success: (response) =>
        if response.ok
          @set('representations', "#{response.new_representation.representation_id}": response.new_representation )

        callback
          success: response.ok == true
          data: response

      error: (response) ->
        callback
          success: false
          data: response

  deleteThumb: (callback) ->
    $.ajax
      url: "#{@url()}&deletethumb=1"
      type: 'POST'
      dataType: 'json'
      data: null
      beforeSend: (xhr) ->
        token = Model.getXSRFCookie()
        xhr.setRequestHeader('X-XSRF-TOKEN', token) if token?
      success: (response) =>
        if response.ok
          @set('representations', null)

        callback
          success: response.ok == true
          data: response

      error: (response) ->
        callback
          success: false
          data: response

  getPrimaryRepresentation: ->
    list = @get('representations')

    return null unless list? and not _.isEmpty(list)
    _.find list, (item) -> item.is_primary == '1'

  getPrimaryImageUrl: ->
    item = @getPrimaryRepresentation()
    return null unless item?.urls?.original? and item.mimetype in ['image/jpeg', 'image/png']

    @updateUrl(item.urls.original)

  getPrimaryThumbUrl: ->
    item = @getPrimaryRepresentation()
    return null unless item?.urls?.preview170?

    @updateUrl(item.urls.preview170)

  getAnyImageUrl: ->
    url = @getPrimaryImageUrl()

    unless url?
      url = @getPrimaryThumbUrl()

    url

  # Temporary
  updateUrl: (url) ->
    return null unless url?

    pathIndex = url.indexOf('media')
    return null unless pathIndex > -1

    path = url.substring(pathIndex)
    "#{window.settings.videoUrlBase}#{path}"


  getMediaType: ->
    representation = @getPrimaryRepresentation()
    return null unless representation?

    switch representation.mimetype
      when 'image/jpeg', 'image/png'
        return 'image'

      when 'video/mp4'
        return 'video'

      else
        return null