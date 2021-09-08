utils             = require 'lib/utils'
Chaplin           = require 'chaplin'
View              = require 'views/base/view'
ObjectDefinitions = require 'models/object-definitions'

module.exports = class DetailSummaryView extends View
  autoRender: true
  className: 'bg-white p-3 mb-3'

  template: require './templates/summary'
  listTemplate: require './templates/summary-list'

  definitions: null
  summaryIndex: 0
  summary: null

  events:
    'change #summary-select': 'changeSelect'
    'change #summary-select-filter': 'changeSelectFilter'
    'click .button-switch-to-edit': 'clickEdit'
    'click .summary-image': 'clickImage'
    'click .button-open-media': 'clickImage'

  initialize: (data) ->
    if data.definitions?
      @definitions = _.clone(data.definitions)
    else
      @definitions = []

    @parentView = data.parent
    @addAllToDefinitions()
    super(data)

  addAllToDefinitions: ->
    objectType = @model.getObjectType()
    
    list = []
    hasThumbnail = false

    for group in objectType.groups
      switch(group.type)
        when 'thumb'
          hasThumbnail = true

        when 'data'
          for attrGroup in group.attrGroups
            if attrGroup == 'idno'
              list.push
                key: 'idno'
                label: 'attr.idno'

            else if attrGroup.indexOf('preferredLabel') == 0
              list.push
                key: attrGroup
                label: 'attr.preferred_label'

            else
              list.push(attrGroup)

        when 'relations'
          for attrGroup in group.attrGroups
            list.push(attrGroup)

    if list.length > 0
      plainList = _.map list, (attr) -> if typeof attr == 'string' then attr else attr.key
      definitions = ObjectDefinitions.createAttrGroups(plainList, @model.objectType)

      @definitions.unshift
        label: lang._('label.summary_all')
        showThumbnail: hasThumbnail
        definitions: definitions
        showThumbnail: true
        attrs: list

  buildList: ->
    return [] unless @definitions?[@summaryIndex]

    @summary = []

    definition = @definitions[@summaryIndex]

    for defItem, index in definition.definitions
      attrItem = definition.attrs[index]
      
      if typeof attrItem == 'string'
        attrKey = attrItem
        attrItem = {}
        
      else
        attrKey = attrItem.key

      label = if attrItem.label? then lang._(attrItem.label) else defItem.label

      if defItem.key == 'intrinsic_fields'
        values = [@model.get('intrinsic_fields')[attrKey]]

      else if defItem.key == 'related'
        label = lang._(defItem.labelCode)
        values = []
        relatedItems = @model.get('related')

        if relatedItems?[defItem.relationKey]?
          for relatedItem in relatedItems[defItem.relationKey]
            url = Chaplin.utils.reverse(defItem.controllerPath, id: relatedItem[defItem.idKey])
            attrValues = []

            for attrKey in defItem.attrKeys
              if attrKey?.length > 0
                attrValues.push(relatedItem[attrKey])

            if attrValues.length > 0
              if defItem.relatedAttrs?.length > 0 and relatedItem.related_attributes?
                relatedAttrs = []

                for relatedAttrDefinition in defItem.relatedAttrs
                  splittedKey = relatedAttrDefinition.key.split('.')

                  if splittedKey.length == 2
                    relatedAttrObject = relatedItem.related_attributes[splittedKey[0]]
                    
                    if relatedAttrObject?
                      relatedValues = _.map relatedAttrObject, (item) ->
                        item[splittedKey[1]]

                      relatedAttrs.push("<span title=\"#{lang._(relatedAttrDefinition.labelKey)}\">#{relatedValues.join(', ')}</span>")

                relatedAttrs = " #{relatedAttrs.join(', ')}"

              else
                relatedAttrs = ''

              values.push(utils.renderLink(url, attrValues.join('; ')) + "#{relatedAttrs} (#{relatedItem.item_type_name}, #{relatedItem.relationship_typename})")

      else
        values = []

        switch defItem.key
          when 'preferred_labels'
            modelAttrs = @model.get('preferred_labels')

          else
            modelAttrs = @model.get(defItem.key)

        if modelAttrs?
          for modelAttr in modelAttrs
            valueArray = []

            if attrItem.attrs?
              for attrKey in attrItem.attrs
                value = modelAttr[attrKey]
                
                if value?.data?
                  valueArray.push(utils.formatAttr(value.data, value.label, null, null, modelAttr))

            else
              for subAttrItem in defItem.items
                value = modelAttr[subAttrItem.key]
                valueType = if subAttrItem.type == 'geocode' then null else subAttrItem.type
                if typeof value == 'string'
                  valueArray.push(utils.formatAttr(value, value, valueType, subAttrItem, modelAttr))

                else if value?.data?
                  valueArray.push(utils.formatAttr(value.label, value.data, valueType, subAttrItem, modelAttr))

            if valueArray.length > 0
              joinedValues = valueArray.join('; ')
              
              if modelAttr._value_source?.length > 0
                if attrItem.inline == true
                  joinedValues += " <span class=\"summary-value-source\" title=\"#{lang._ 'label.value_source'}\">#{_.escape(modelAttr._value_source)}</span>"

                else
                  joinedValues += "<br /><span class=\"summary-value-source\" title=\"#{lang._ 'label.value_source'}\">#{_.escape(modelAttr._value_source)}</span>"

              values.push(joinedValues)


      if values.length > 0
        if attrItem.inline == true
          values = values.join(' / ')
        else 
          values = '<div class="summary-relation-item">' + values.join('</div><div class="summary-relation-item">') + '</div>'

      else
        values = ''

      @summary.push
        label: label
        values: values
        description: defItem.description

  getTemplateData: ->
    label: @model.getPreferredLabel()
    summaryIndex: @summaryIndex
    definitions: @definitions
    
  attach: ->
    super()
    @renderList()

  renderList: ->
    @buildList()

    @$el.find('.summary-list').html @listTemplate
      summary: @summary
      mediaType: @model.getMediaType()
      objectType: @model.getObjectTypeLabel()
      imageUrl: if @definitions[@summaryIndex].showThumbnail then @model.getAnyImageUrl() else null

    @activateTooltips()

  changeSelect: (event) ->
    @summaryIndex = parseInt($(event.currentTarget).val())
    @renderList()


  changeSelectFilter: (event) ->
    @$el.find('.summary-list').toggleClass('show-all', $(event.currentTarget).val() == 'all')

  clickEdit: ->
    @parentView?.switchToEditMode(@model)
  
  clickImage: (event) ->
    @parentView?.showMediaOverlay(@model)

