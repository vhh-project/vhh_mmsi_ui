require 'views/elements/partials'
utils     = require 'lib/utils'
mediator  = require 'mediator'
View      = require 'views/base/view'
ModalView = require 'views/elements/modal-view'

module.exports = class DetailDataView extends View
  autoRender: true
  template: require './templates/data'
  editTemplate: require './templates/edit'
  errorTemplate: require './templates/errors'

  definitions: null

  events:
    'click .button-new-attr': 'clickNew'
    'click .button-detail-edit': 'clickEdit'
    'click .button-detail-delete': 'clickDelete'
    'submit form': 'submit'
    'click .button-cancel': 'clickCancel'
    'click .button-change-relation': 'clickChangeRelation'
    'blur .map-geocode-edit + input': 'changeGeocodeInput'
    'keydown .map-geocode-edit + input': 'keydownGeocodeInput'

  initialize: (data) ->
    @canEdit = data.canEdit == true
    @definitions = data.definitions
    @updateCallback = data.updateCallback
    @parentView = data.parent

    @buildDefinitions()

    super(data)

  render: ->
    for definition, index in @definitions
      if definition.single == true and definition.attrs.length > 1
        feedback = "<div class=\"alert alert-warning\">#{lang._('message.single_with_multiple_entries')}</div>"

      else
        feedback = null

      @$el.append(@renderTemplate(definition, index, feedback))

  attach: ->
    super()

    @activateTooltips()

    @addMaps @$el.find('.map-geocode-details:not(.leaflet-container)'),
      centerButton: true
      imageOverlays: true
      imageOverlayButton: false

  renderTemplate: (definition, index, feedback) ->
    if definition.label?
      label = definition.label

    else
      label = lang._(definition.labelCode)

    @template
      definition: definition
      label: label
      index: index
      feedback: feedback
      showCounterBadge: definition.attrs.length == 0 or definition.single != true
      canEdit: @canEdit and definition.canEdit != false
      canDelete: @canEdit and definition.key != 'intrinsic_fields' and (not definition.minItems? or definition.minItems < definition.attrs.length)
      canAdd: @canEdit and (definition.attrs.length == 0 or definition.single != true)

  buildDefinitions: ->
    for definition in @definitions
      @buildDefinition(definition)

  buildDefinition: (definition) ->
    definition.attrs = []
    definition.emptyAttr = []

    attributes = @model.attributes

    # Map attribute keys and create item labels if necessary
    for item in definition.items
      item.attrKey = definition.key unless item.attrKey?
      
      unless item.label?
        if item.labelCode?
          item.label = lang._(item.labelCode)

        else if item.key?
          item.label = lang._("attr.#{item.key}") 

      definition.emptyAttr.push
        index: null
        defItem: item
        value: ''
        originalValue: null
    
    # Map attributes
    modelAttrs = attributes[definition.key] or []   

    if definition.key == 'intrinsic_fields'
      attr = []

      for item in definition.items
        value = modelAttrs[item.key]

        attr.push
          index: 0
          defItem: item
          value: utils.formatAttr(value, value, null, item, modelAttrs)
          originalValue: value

      definition.attrs.push
        attr: attr
        valueSource: false

    else
      for modelAttr, attrIndex in modelAttrs
        attr = []

        for item in definition.items
          switch item.attrKey
            when 'preferred_labels'
              labelValue =  modelAttrs[attrIndex][item.key]
              dataValue = labelValue
              valueSource = false

            else
              if modelAttr[item.key]?
                if _.isObject(modelAttr[item.key])
                  labelValue = modelAttr[item.key].label
                  dataValue = modelAttr[item.key].data

                else
                  labelValue = dataValue = modelAttr[item.key]
              else
                labelValue = null
                dataValue = null
                
              valueSource = modelAttrs[attrIndex]['_value_source']

          attr.push
            index: attrIndex
            defItem: item
            value: utils.formatAttr(labelValue, dataValue, item.type, item, modelAttr)
            labelValue: labelValue
            originalValue: dataValue

        definition.attrs.push
          attr: attr
          valueSource: valueSource

  clickNew: (event) ->
    @createEditFormForButton($(event.currentTarget), true)

  clickEdit: (event) ->
    @createEditFormForButton($(event.currentTarget), false)

  createEditFormForButton: ($button, isNew) ->
    @removeForm()

    index = $button.data('index')
    definition = @definitions[index]

    if isNew
      attrIndex = null
      attr = 
        attr: definition.emptyAttr
        valueSource: null

    else
      attrIndex = $button.data('attr-index')
      attr = definition.attrs[attrIndex]

    html = @editTemplate
      index: index
      definition: definition
      attrIndex: attrIndex
      attr: attr
      isNew: isNew

    if isNew
      $cardBody = $button.closest('.detail-row').find('.card-body')
      $cardBody.append(html)
      $form = $cardBody.find('.detail-attr-row:last')

    else
      $row = $button.closest('.detail-attr-row')
      $row.after(html)
      $form = $row.next()
      $row.hide()
    
    window.setTimeout(
      =>
        @editTemplateCreated($form)
      , 10
    )

  editTemplateCreated: ($form) ->
    mediator.publish('application:editing', true)

    @activateTooltips()

    # Add autofocus
    $form.find(':input:first').focus()

    # Add maps for geolocation fields
    $form.find('.map-geocode-edit').each (index, map) =>
      $map = $(map)
      @editedMaps = @addMaps $map,
        $targetInput: $map.next('input')
        centerButton: true
        imageOverlays: true
        imageOverlayButton: true
        settingsKey: 'mapGeocodeEditSettings'

    # Scroll to form
    @scrollTo($form, -12)

    # Add autosuggest
    utils.addLookupToInput($form.find('.input-lookup'), @model.objectType)

  clickDelete: (event) ->
    @removeForm()

    $button = $(event.currentTarget)
    $row = $button.closest('.detail-attr-row')

    definitionIndex = $button.data('index')
    attrIndex = $button.data('attr-index')

    definition = @definitions[definitionIndex]
    content = lang._('message.confirm_delete')

    if definition.idKeys?
      labels = []
      attr = definition.attrs[attrIndex]

      for idKey in definition.idKeys
        attrValue = _.find attr.attr, (item) ->
          item.defItem.key == idKey

        labels.push attrValue.value if attrValue?.value?

      if labels.length > 0
        content += "<div class=\"alert alert-secondary\">#{labels.join(' ')}</div>"

    new ModalView
      header: "#{lang._('header.delete')} #{lang._(definition.label)}"
      content: content
      confirmText: lang._('button.delete')
      parent: @
      callback: =>
        @addSpinner($row)

        if definition.key == 'preferred_labels'
          @model.deletePreferredLabel attrIndex, (response) =>
            if response.success == true
              @updateCallback?()
              @reRenderDetail(definitionIndex, lang._('message.preferred_label_deleted'), true)

        else
          @model.deleteAttribute definition.key, attrIndex, (response) =>
            if response.success == true
              @updateCallback?()
              @reRenderDetail(definitionIndex, lang._('message.attribute_deleted'), true)

        true

  submit: (event) ->
    event.preventDefault()
    $form = $(event.currentTarget)
    $form.find('.detail-errors').remove()
    $form.find('.invalid-feedback').remove()
    index = $form.closest('.detail-row').data('index')

    definition = @definitions[$form.data('index')]
    data = @model.validate($form, definition)

    if @editedMaps?
      @removeMaps(@editedMaps)
      delete @editedMaps

    if data?
      @addSpinner($form)

      @model.saveAttributes data, (response) =>
        @removeSpinner($form)

        if response.success == true
          @saveDataCallback(index)

        else
          if response.errors?.length > 0
            @showErrors($form, response.errors)

          else
            @showErrors($form, [lang._('error.unkown_api_error')])

  saveDataCallback: (definitionIndex) =>
    mediator.publish('application:editing', false)

    @model.fetch
      success: =>
        @updateCallback?()
        @reRenderDetail(definitionIndex, lang._('message.attribute_updated'), true)
      
      error: =>
        @reRenderDetail(definitionIndex, lang._('message.api_fetch_error'), false)

  reRenderDetail: (definitionIndex, message, success = true) ->
    definition = @definitions[definitionIndex]
    @buildDefinition(definition)

    if message?
      if success
        feedback = "<div class=\"alert alert-success mb-0\">#{message}</div>"

      else
        feedback = "<div class=\"alert alert-danger mb-0\">#{message}</div>"

    else
      feedback = null

    $row = @$el.find(".detail-row[data-index=\"#{definitionIndex}\"]")

    $row.find('.map-geocode-details.leaflet-container')

    $row.find('.map-geocode-details.leaflet-container').each (mapIndex, mapNode) =>
      @removeMapById(mapNode.getAttribute('leaflet-id'))

    @removeTooltips($row)

    $row.replaceWith(@renderTemplate(definition, definitionIndex, feedback))
    @activateTooltips()
    
    $row = @$el.find(".detail-row[data-index=\"#{definitionIndex}\"]")
    @addMaps @$el.find('.map-geocode-details:not(.leaflet-container)'),
      centerButton: true
      imageOverlays: true
      imageOverlayButton: false

  showErrors: ($form, errorList) ->
    $form.prepend @errorTemplate errors: errorList
  
  clickCancel: (event) ->
    mediator.publish('application:editing', false)
    $form = $(event.currentTarget).closest('form')
    @removeTooltips($form)
    @removeForm($form)

  clickChangeRelation: (event) ->
    $button = $(event.currentTarget)
    objectType = $button.data('object-type')

    @parentView?.startChangeRelation objectType, (id, label, typeId) ->
      $parent = $button.closest('.change-relation-group')
      $parent.find('input[type="hidden"]').val(id)
      $parent.find('input[type="text"]').val(label)

  changeGeocodeInput: (event) ->
    $input = $(event.currentTarget)
    $map = $input.parent().find('.map-geocode-edit')

    leafletId = $map.attr('leaflet-id')
    map = @getMapById($map.attr('leaflet-id'))

    geocodes = utils.parseGeocode($input.val())
    map.featureGroup.clearLayers()
    @mapAddGeocodes(map, geocodes)
    @mapUpdateLayers(map)

  keydownGeocodeInput: (event) ->
    if event.key == 'Enter'
      event.stopPropagation()
      event.preventDefault()
      event.currentTarget.blur()

  removeForm: ($form) ->
    mediator.publish('application:editing', false)

    if @editedMaps?
      @removeMaps(@editedMaps, true)
      delete @editedMaps

    $form = @$el.find('form') unless $form?
    $form.prev().show()
    $form.remove()

  keyupLookup: (event) ->
    $input = $(event.currentTarget)
    #$inputdata = 
    $input.suggest('@', {
      data: [
        { value: 'a', text: 'a' }
      ]
    })


