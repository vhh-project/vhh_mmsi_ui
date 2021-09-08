utils             = require 'lib/utils'
mediator          = require 'mediator'
View              = require 'views/base/view'
ModalView         = require 'views/elements/modal-view'
ObjectDefinitions = require 'models/object-definitions'

module.exports = class DetailRelationsView extends View
  autoRender: true
  template: require './templates/relations'
  editTemplate: require './templates/edit'
  changeTemplate: require './templates/change-relation'
  errorTemplate: require './templates/errors'

  events:
    'click .button-new-relation': 'clickNew'
    'click .button-relations-edit': 'clickEdit'
    'click .interstitial-dropdown .dropdown-item': 'clickNewInterstitial'
    'click .button-interstital-edit': 'clickEditInterstitial'
    'click .button-relations-delete': 'clickDelete'
    'click .button-interstital-delete': 'clickDeleteInterstitial'
    'submit .card-body > form': 'submit'
    'submit .relation-interstitial-wrapper > form': 'submitInterstitial'
    'click .button-cancel': 'clickCancel'
    'click .button-change-relation': 'clickChangeRelation'

  initialize: (data) ->
    @canEdit = data.canEdit == true
    @definitions = data.definitions
    @updateCallback = data.updateCallback
    @parentView = data.parent

    @buildDefinitions()

    super(data)

  render: ->
    for definition, index in @definitions
      @$el.append(@renderTemplate(definition, index))

  getDefinitionLabel: (definition) ->
    if definition.label?
      label = definition.label

    else
      label = lang._(definition.labelCode)

  renderTemplate: (definition, index, feedback) ->
    @template
      definition: definition
      hasInterstitalDefinitions: definition.definitions?.length > 0
      label: @getDefinitionLabel(definition)
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

    relations = @model.get('related')
    return unless relations?

    list = relations[definition.relationKey]
    return unless list?

    definition.attrs = list

    for attr in definition.attrs
      attr._relationId = attr[definition.idKey]
      attr.objectTypeName = attr.item_type_name
      attr.definitions = []

      for relationDefinition in definition.definitions
        relationDefinition.attrs = []
        relationDefinition.emptyAttr = []
        clonedDefinition = _.clone(relationDefinition)
        @buildAttributeDefinition(clonedDefinition, attr.attributes or [])
        attr.definitions.push(clonedDefinition)

      if definition.relatedAttrs?.length > 0 and attr.related_attributes?
        attr.relatedAttrs = []
        
        for relatedAttrDefinition in definition.relatedAttrs
          splittedKey = relatedAttrDefinition.key.split('.')

          if splittedKey.length == 2
            relatedAttrObject = attr.related_attributes[splittedKey[0]]
            
            if relatedAttrObject?
              relatedValues = _.map relatedAttrObject, (item) ->
                item[splittedKey[1]]

              attr.relatedAttrs.push
                label: lang._(relatedAttrDefinition.labelKey)
                value: relatedValues.join(', ')

  buildAttributeDefinition: (definition, attributes) ->
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

    for modelAttr, attrIndex in modelAttrs
      attr = []

      for item in definition.items
        if modelAttr[item.key]?
          if _.isObject(modelAttr[item.key])
            labelValue = modelAttr[item.key].label
            dataValue = modelAttr[item.key].data

          else
            labelValue = dataValue = modelAttr[item.key]
        else
          labelValue = null
          dataValue = null

        attr.push
          index: attrIndex
          defItem: item
          value: utils.formatAttr(labelValue, dataValue, item.type, item, modelAttr)
          labelValue: labelValue
          originalValue: dataValue

      definition.attrs.push
        attr: attr
        valueSource: modelAttr._value_source

  clickNew: (event) ->
    @createEditFormForButton($(event.currentTarget))

  getRelationshipTypes: (relationKey, otherTypeId, relationTypeId, reverse) ->
    typeId = @model.getTypeId()

    list = []

    for key, item of @model.getRelationshipTypes(relationKey)
      list.push
        id: item.type_id
        key: item.key
        label: item.typename
        depth: item.depth
        reverse: false
        selected: relationTypeId? and relationTypeId == item.type_id and not reverse
        disabled: (item.sub_type_left_id? and item.sub_type_left_id != typeId) or 
          (item.sub_type_right_id? and item.sub_type_right_id != otherTypeId)

      if item.typename != item.typename_reverse
        list.push
          id: item.type_id
          key: item.key
          label: item.typename_reverse
          depth: item.depth
          selected: relationTypeId? and relationTypeId == item.type_id and reverse
          reverse: true
          disabled: (item.sub_type_left_id? and item.sub_type_left_id != otherTypeId) or 
            (item.sub_type_right_id? and item.sub_type_right_id != typeId)
    list

  createEditFormForButton: ($button) ->
    @removeForm()

    index = $button.data('index')
    definition = @definitions[index]

    # relationshipTypes = @getRelationshipTypes(definition.relationKey)
    relationshipTypes = []

    for relationshipType in relationshipTypes
      if relationshipType.key?
        relationshipType.label += " (#{relationshipType.key})"

    $cardBody = $button.closest('.detail-row').find('.card-body')

    $cardBody.append @editTemplate
      index: index
      header: "#{lang._('button.add')} #{@getDefinitionLabel(definition)}"
      definition: {}
      attrIndex: null
      attr:
        valueSource: false
        attr: [
          {
            originalValue: null
            labelValue: null
            index: 0
            defItem:
              attrKey: definition.relationKey
              key: 'related'
              cols: 6
              label: lang._('label.related_item')
              required: true
              type: 'relation'
              objectType: definition.relationKey
          }
          {
            originalValue: null
            labelValue: relationshipTypes
            index: 1
            defItem:
              attrKey: definition.relationKey
              key: 'relationType'
              cols: 6
              label: 'TYPE'
              required: true
              type: 'relationType'
          }
        ]

      isNew: true

    $form = $cardBody.find('.detail-attr-row:last')

    $form.find('button:first').focus()
    $form.find('select').prop('disabled', true)

    window.setTimeout(
      =>
        @editTemplateCreated($form)
      , 10
    )

  editTemplateCreated: ($form) ->
    mediator.publish('application:editing', true)

    # Add autofocus
    $form.find(':input:first').focus()

    # Scroll to form
    @scrollTo($form, -12)

  submit: (event) ->
    event.preventDefault()

    $form = $(event.currentTarget)
    $form.find('.detail-errors').remove()
    index = $form.closest('.detail-row').data('index')

    definition = @definitions[index]

    $id = $form.find('input[type="hidden"]')
    $select = $form.find('select')
    error = false

    id = $id.val()

    relatedObjectType = $id.data('attr-key')
    
    unless id?.length > 0
      @showRequiredError($id)
      error = true

    relationshipTypeId = $select.val()
    reverse = false

    splittedId = relationshipTypeId.split('.')
    if splittedId.length == 2
      relationshipTypeId = splittedId[0]
      reverse = splittedId[1] == 'reverse'


    unless relationshipTypeId?.length > 0
      @showRequiredError($select)
      error = true

    return if error

    @addSpinner($form)

    data =
      'new':
        "#{relatedObjectType}": [
          {
            type_id: relationshipTypeId
            "#{definition.idKey}": id
            direction: if reverse then 'rtol' else 'ltor'
          }
        ]

    @model.saveRelations data, (response) =>
      @removeSpinner($form)

      if response.success == true
        @saveDataCallback(index)

      else
        if response.errors?.length > 0
          @showErrors($form, response.errors)

        else
          @showErrors($form, [lang._('error.unkown_api_error')])

  submitInterstitial: (event) ->
    event.preventDefault()

    $form = $(event.currentTarget)
    $form.find('.detail-errors').remove()
    index = $form.data('index')
    attrIndex = $form.data('attr-index')
    
    definition = @definitions[index]
    
    interstitialDefinition = _.find definition.attrs[attrIndex].definitions, (item) =>
      item.key == @currentInterstitial.key

    data = @validateInterstitial($form, interstitialDefinition)

    return unless data?

    if @currentInterstitial.index?
      interstitialId = definition.attrs[attrIndex].attributes[@currentInterstitial.key][@currentInterstitial.index]._id
    
    else
      interstitialId = null

    @addSpinner($form)

    @model.saveInterstitial definition.relationKey, attrIndex, @currentInterstitial.key, interstitialId, data, (response) =>
      @removeSpinner($form)

      if response.success == true
        @saveDataCallback(index)

      else
        if response.errors?.length > 0
          @showErrors($form, response.errors)

        else
          @showErrors($form, [lang._('error.unkown_api_error')])

  validateInterstitial: ($form, definition) ->
    data = {}
    error = false

    $form.find('.form-control:not(.label-only)').each (nodeIndex, node) =>
      $node = $(node)
      $col = $node.closest('.edit-form-col')
      errorText = null
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
        data[key] = value

    if error == true
      return null

    else
      return data

  showRequiredError: ($formElement) ->
    $formElement.closest('div').append("<div class=\"invalid-feedback\">#{lang._('form.required')}</div>")
    $formElement.addClass('is-invalid')

  saveDataCallback: (definitionIndex) =>
    mediator.publish('application:editing', false)

    @model.fetch
      success: =>
        @updateCallback?()
        @reRenderDetail(definitionIndex, lang._('message.attribute_updated'), true)
      
      error: =>
        @reRenderDetail(definitionIndex, lang._('message.api_fetch_error'), false)
  
  showErrors: ($form, errorList) ->
    $form.prepend @errorTemplate errors: errorList

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
    $row.replaceWith(@renderTemplate(definition, definitionIndex, feedback))
    
    $row = @$el.find(".detail-row[data-index=\"#{definitionIndex}\"]")

  removeForm: ($form) ->
    $form = @$el.find('form') unless $form?
    $form.prev().show()
    $form.remove()

  clickChangeRelation: (event) ->
    $button = $(event.currentTarget)
    objectType = $button.data('object-type')
    @parentView?.startChangeRelation objectType, (id, label, typeId) =>
      @changedSelect(id, label, typeId, $button.closest('form'), objectType)

  changedSelect: (id, label, typeId, $form, objectType) ->
    $form.find('input[type="hidden"]').val(id)
    $form.find('input[type="text"]').val(label)
    $select = $form.find('select')

    $select.prop('disabled', false)

    relationshipTypes = @getRelationshipTypes(objectType, typeId)

    $select.find('option:not(:first-child)').remove()

    for item in relationshipTypes
      id = item.id

      if item.reverse
        id += '.reverse'

      html = ["<option value=\"#{id}\""]
      html.push(' selected') if item.selected
      html.push(' disabled') if item.disabled
      
      html.push('>')

      if item.depth > 0
        html.push(_.repeat('&nbsp;&nbsp;&nbsp;', item.depth))

      html.push(item.label)

      if item.key?
        html.push(" (#{item.key})")

      html.push('</option>')

      $select.append(html.join(''))

  clickEdit: (event) ->
    @removeForm()

    $button = $(event.currentTarget)
    $row = $button.closest('.detail-attr-row')

    definitionIndex = $button.data('index')
    attrIndex = $button.data('attr-index')

    definition = @definitions[definitionIndex]
    attr = definition.attrs[attrIndex]
    relationshipTypes = @getRelationshipTypes(definition.relationKey, attr.item_type_id, attr.type_id, attr.direction == 'rtol')

    new ModalView
      header: lang._('header.edit_relation_type')
      content: @changeTemplate
        attr: attr
        relationshipTypes: relationshipTypes
      confirmText: lang._('button.save')
      parent: @
      callback: ($content) =>
        @addSpinner($row)
        newTypeId = $content.find('select').val()
        reverse = false

        splittedTypeId = newTypeId.split('.')

        if splittedTypeId.length == 2
          newTypeId = splittedTypeId[0]
          reverse = splittedTypeId[1] == 'reverse'

        @model.updateRelation definition.relationKey, definition.idKey, attrIndex, newTypeId, reverse, (response) =>
          @removeSpinner($row)
          if response.success == true
            @updateCallback?()
            @reRenderDetail(definitionIndex, lang._('message.relation_type_updated'), true)
        
        true

  clickEditInterstitial: (event) ->
    $button = $(event.currentTarget)
    index = $button.data('index')
    attrIndex = $button.data('attr-index')
    interstitialKey = $button.data('interstitial-key')
    valueIndex = $button.data('value-index')
    
    @createEditInterstitialForm(
      index,
      attrIndex,
      interstitialKey,
      valueIndex,
      $button.closest('.relation-interstitial')
    )

  clickNewInterstitial: (event) ->
    $button = $(event.currentTarget)
    $dropdown = $button.closest('.interstitial-dropdown')
    index = $dropdown.data('index')
    attrIndex = $dropdown.data('attr-index')
    interstitialKey = $button.data('key')
    
    @createEditInterstitialForm(
      index,
      attrIndex,
      interstitialKey,
      null,
      $dropdown.closest('.detail-attr-row').find('.relation-interstitial-wrapper')
    )

  createEditInterstitialForm: (index, attrIndex, interstitialKey, valueIndex, $container) ->
    @removeForm()

    definition = @definitions[index]
    interstitialDefinition = _.find definition.attrs[attrIndex].definitions, (item) ->
      item.key == interstitialKey

    if valueIndex?
      header = "#{lang._('button.edit')} #{lang._(interstitialDefinition.labelKey)}"
      interstitialAttr = interstitialDefinition.attrs[valueIndex]

    else
      header = "#{lang._('button.add')} #{lang._(interstitialDefinition.labelKey)}"
      interstitialAttr =
        attr: interstitialDefinition.emptyAttr
        valueSource: null

    @currentInterstitial =
      key: interstitialKey
      index: valueIndex

    html = @editTemplate
      index: index
      header: header
      definition: interstitialDefinition
      attrIndex: attrIndex
      attr: interstitialAttr
      isNew: false

    if valueIndex?
      $container.after(html)
      $form = $container.next()
      $container.hide()

    else
      $container.append(html)
      $form = $container.find('.detail-attr-row:last')

    window.setTimeout(
      =>
        @editTemplateCreated($form)
      , 10
    )

  clickDelete: (event) ->
    @removeForm()

    $button = $(event.currentTarget)
    $row = $button.closest('.detail-attr-row')

    definitionIndex = $button.data('index')
    attrIndex = $button.data('attr-index')

    definition = @definitions[definitionIndex]
    attr = definition.attrs[attrIndex]
    content = "#{lang._('message.confirm_delete_relation')}<br /><strong>#{attr.label}</strong> <em>(#{attr.relationship_typename})</em>."
    
    new ModalView
      header: lang._('header.delete_relation')
      content: content
      confirmText: lang._('button.delete')
      parent: @
      callback: =>
        @addSpinner($row)

        @model.deleteRelation definition.relationKey, attrIndex, (response) =>
          if response.success == true
            @updateCallback?()
            @reRenderDetail(definitionIndex, lang._('message.attribute_deleted'), true)

        true

  clickDeleteInterstitial: (event) ->
    @removeForm()

    $button = $(event.currentTarget)
    $row = $button.closest('.relation-interstitial')

    definitionIndex = $button.data('index')
    attrIndex = $button.data('attr-index')
    interstitialKey = $button.data('interstitial-key')
    valueIndex = $button.data('value-index')

    definition = @definitions[definitionIndex]
    interstitialAttr = definition.attrs[attrIndex].attributes[interstitialKey][valueIndex]

    new ModalView
      header: lang._('header.delete_interstitial')
      content: lang._('message.delete_interstitial')
      confirmText: lang._('button.delete')
      parent: @
      callback: =>
        @addSpinner($row)

        @model.deleteInterstitial definition.relationKey, attrIndex, interstitialKey, valueIndex, (response) =>
          if response.success == true
            @updateCallback?()
            @reRenderDetail(definitionIndex, lang._('message.interstitial_deleted'), true)

        true

  clickCancel: (event) ->
    mediator.publish('application:editing', false)
    $form = $(event.currentTarget).closest('form')
    @removeForm($form)