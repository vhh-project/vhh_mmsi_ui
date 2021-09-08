attrGroups    = require 'models/data/attr-groups'
objectGroups  = require 'models/data/object-groups'

relationGroups = require 'models/data/relation-groups'
relationAttrGroups = require 'models/data/relation-attr-groups'

module.exports = class ObjectDefinitions
  # Already loaded definitions from CA
  @caDefinitions = {}

  @attrGroups: attrGroups
  @objectGroupsByTypeId: objectGroups

  @relationGroups: relationGroups
  @relationAttrGroups: relationAttrGroups

  @warnings = {}
  @attrWarnings = {}
  @attrsToIgnore = [
    'description'
    'description_source'
    'external_link'
    'internal_notes'
    'coverageNotes'
    'coverageDates'
    'formatNotes'
    'lcsh_terms'
    'rights'
    'address'
    'telephone'
    'email'
    'biography'
    'biography_source'
  ]

  @loadCaDefinition: (caObjectType, callback) ->
    if _.has(ObjectDefinitions.caDefinitions, caObjectType)
      callback
        success: true

    else
      $.ajax
        type: 'GET'
        dataType: 'json'
        url: "#{window.settings.apiUrl}ca/service/model/#{caObjectType}"
        success: (response) ->
          if response.ok == true

            ObjectDefinitions.caDefinitions[caObjectType] = response
            ObjectDefinitions.mapCaDefinitions(caObjectType)
            callback
              success: true

          else
            callback
              success: false

        error: ->
          callback
            success: false

  @warn: (objectType, defintionType, attrKey, warning) ->
    @warnings[objectType] = [] unless @warnings[objectType]
    @warnings[objectType].push(warning)

    if defintionType? and attrKey?
      @attrWarnings[objectType] = {} unless @attrWarnings[objectType]?
      @attrWarnings[objectType][defintionType] = {} unless @attrWarnings[objectType][defintionType]?
      @attrWarnings[objectType][defintionType][attrKey] = [] unless @attrWarnings[objectType][defintionType][attrKey]?
      @attrWarnings[objectType][defintionType][attrKey].push warning

    console.warn("[#{objectType}]", warning)

  @mapCaDefinitions: (caObjectType) ->
    definitionObject = ObjectDefinitions.objectGroupsByTypeId[caObjectType]
    caDefinitionObject = ObjectDefinitions.caDefinitions[caObjectType]

    unless definitionObject?
      ObjectDefinitions.warn(caObjectType, null, null, 'No defintionObject found')

    unless caDefinitionObject?
      ObjectDefinitions.warn(caObjectType, null, null, 'No caDefintionObject found')

    return unless definitionObject? and caDefinitionObject?

    for definitionTypeKey, caDefinitionType of caDefinitionObject
      if definitionTypeKey != 'ok'
        definitionType = definitionObject[definitionTypeKey]

        unless definitionType?
          ObjectDefinitions.warn(caObjectType, null, null, "Collective Access defines a model type \"#{definitionTypeKey}\" which is not represented in the MMSI config")

        else
          coveredAttributeKeys = []

          # TODO reverse checking unfinished
          for group in definitionType.groups
            if group.type == 'data'
              for attrGroupKey in group.attrGroups
                attrGroup = ObjectDefinitions.attrGroups[attrGroupKey]
                
                if attrGroup?
                  unless attrGroup.key in ['preferred_labels', 'intrinsic_fields']
                    coveredAttributeKeys.push(attrGroup.key)
                    
                    if caDefinitionType.elements[attrGroup.key]?
                      for attrElement in attrGroup.items
                        unless caDefinitionType.elements[attrGroup.key].elements_in_set[attrElement.key]?
                          ObjectDefinitions.warn(caObjectType, definitionTypeKey, attrGroup.key, "The MMSI config defines an element \"#{attrElement.key}\" in the attribute \"#{attrGroup.key}\" for the model \"#{definitionTypeKey}\" which is not represented in Collective Access")

                    else
                      ObjectDefinitions.warn(caObjectType, definitionTypeKey, attrGroup.key, "The MMSI config for the model type \"#{definitionTypeKey}\" defines the attribute \"#{attrGroup.key}\" (tab group \"#{group.tab}\") which is not represented in Collective Access")

                else
                  ObjectDefinitions.warn(caObjectType, definitionTypeKey, attrGroupKey, "The MMSI config error for the model type \"#{definitionTypeKey}\": the attribute group \"#{attrGroupKey}\" is not defined in detail")

          definitionType.typeId = caDefinitionType.type_info.item_id
          definitionType.relationshipTypes = caDefinitionType.relationship_types or {}

          for caElementsKey, caElements of caDefinitionType.elements
            attrGroup = ObjectDefinitions.getAttrGroupByKey(caElementsKey)
            
            if attrGroup?
              unless caElementsKey in coveredAttributeKeys
                ObjectDefinitions.warn(caObjectType, definitionTypeKey, caElementsKey, "Collective Access defines the attribute \"#{caElementsKey}\" for the model type \"#{definitionTypeKey}\" which is not represented in the MMSI config")
                
              if attrGroup.label != false and caElements.name?.length > 0
                attrGroup.label = caElements.name

              attrGroup.description = caElements.description

              for caElementKey, caElement of caElements.elements_in_set
                attr = _.find attrGroup.items, (item) ->
                  item.key == caElementKey

                elementSettings = caElement.settings or {}

                if attr?
                  attr.label = caElement.display_label if caElement.display_label?.length > 0
                  attr.description = caElement.description
                  
                  if elementSettings.default_text?.length > 0
                    attr.placeholder = elementSettings.default_text

                  else if elementSettings.placeholder?.length > 0
                    attr.placeholder = elementSettings.placeholder

                  switch caElement.datatype
                    when 'List'
                      attr.type = 'vocabulary'
                      attr.listId = caElement.list_id
                      attr.required = elementSettings.requireValue == '1'

                    when 'Url'
                      attr.type = 'url'
                      attr.required = elementSettings.minChars? and elementSettings.minChars != '0'

                    when 'Text'
                      attr.required = elementSettings.minChars? and elementSettings.minChars != '0'

                      if elementSettings.suggestExistingValues == '1' and attr.lookup != true
                        attr.lookup = true
                        attr.lookupMinLength = 3

                    when 'DateRange'
                      attr.required = elementSettings.mustNotBeBlank == '1'

                    when 'Entities'
                      attr.type = 'relation'
                      attr.objectType = 'ca_entities'
                      attr.allowedTypes = elementSettings.restrictToTypes

                    when 'Places'
                      attr.type = 'relation'
                      attr.objectType = 'ca_places'
                      attr.allowedTypes = elementSettings.restrictToTypes

                    when 'Geocode'
                      attr.type = 'geocode'

                else
                  ObjectDefinitions.warn(caObjectType, definitionTypeKey, caElementsKey, "Collective Access defines an element \"#{caElementKey}\" in the attribute \"#{caElementsKey}\" for the model \"#{definitionTypeKey}\" which is not represented in the MMSI config")
            
            else if caElementsKey not in ObjectDefinitions.attrsToIgnore
              ObjectDefinitions.warn(caObjectType, definitionTypeKey, caElementsKey, "Collective Access defines the attribute \"#{caElementsKey}\" for the model type \"#{definitionTypeKey}\" which is not represented in the MMSI config")

  @getObjectGroup: (objectType) ->
    return null unless _.has(@objectGroupsByTypeId, objectType)
    @objectGroupsByTypeId[objectType]

  @getSubTypeById: (typeId) ->
    for objectTypeKey, groupsObject of @objectGroupsByTypeId
      for subGroupKey, subGroupObject of groupsObject
        if subGroupObject.typeId == typeId
          return subGroupKey
      
    return null

  @getObjectTypeById: (typeId) ->
    for objectTypeKey, groupsObject of @objectGroupsByTypeId
      objectType = _.find groupsObject, (item) ->
        item.typeId == typeId

      return objectType if objectType?

    return null

  @getAttrGroupByKey: (key) ->
    for attrGroupKey, attrGroup of ObjectDefinitions.attrGroups
      return attrGroup if attrGroup.key == key

    return null

  @getObjectTypeLabel: (typeId) ->
    objectGroup = ObjectDefinitions.getObjectTypeById(typeId)

    if objectGroup?
      objectGroup.label

    else
      'label.unknown'

  @createAttrGroups: (attrGroupKeys, objectType) ->
    result = []

    for key in attrGroupKeys
      if _.has(ObjectDefinitions.attrGroups, key)
        attrGroup = _.clone(ObjectDefinitions.attrGroups[key])
        result.push(attrGroup)

        if attrGroup.key == 'related'
          attrGroup.definitions = ObjectDefinitions.createRelationAttrGroups(objectType, attrGroup.relationKey)

    result

  @createRelationAttrGroups: (typeKey, relationTypeKey) ->
    attrGroups = _.find ObjectDefinitions.relationGroups, (item) ->
      (item.types[0] == typeKey and item.types[1] == relationTypeKey) or (item.types[1] == typeKey and item.types[0] == relationTypeKey)

    return [] unless attrGroups?

    result = []

    for key in attrGroups.groups
      result.push(_.clone(ObjectDefinitions.relationAttrGroups[key]))

    result

  @getRelationshipTypes: (typeId, otherTypeKey) ->
    objectType = ObjectDefinitions.getObjectTypeById(typeId)
    return {} unless objectType?.relationshipTypes?

    objectType.relationshipTypes[otherTypeKey] or {}

  @getAllTypeIdsFilterString: (caObjectType) ->
    definitionObject = ObjectDefinitions.objectGroupsByTypeId[caObjectType]

    return '' unless definitionObject?

    for typeKey, definitionType of definitionObject
      typeId = parseInt(definitionType.typeId)

      unless isNaN(typeId)
        minTypeId = if minTypeId? then Math.min(minTypeId, typeId) else typeId
        maxTypeId = if maxTypeId? then Math.max(maxTypeId, typeId) else typeId

    return '' unless minTypeId? and maxTypeId?
    "[#{minTypeId} to #{maxTypeId}]"









