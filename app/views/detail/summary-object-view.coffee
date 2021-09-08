utils             = require 'lib/utils'
Chaplin           = require 'chaplin'
CaObject          = require 'models/ca-object'
ObjectDefinitions = require 'models/object-definitions'
View              = require 'views/base/view'
DetailSummaryView = require 'views/detail/summary-view'

module.exports = class DetailSummaryObjectView extends View
  autoRender: false
  className: 'summary-object-view'
  template: require './templates/summary-object'
  itemTemplate: require './templates/summary-object-item'

  creationTree: null
  modelsById: null
  manifestationFetchCount: 0
  itemFetchCount: null

  events:
    'click .summary-nav-labels': 'clickNavItem'

  initialize: (data) ->
    @parentView = data.parent
    super(data)

    @modelsById = {}
    @modelsById[@model.id] = @model

    switch @model.subType
      when 'av_creation', 'nonav_creation'
        @creationTree =
          model: @model
          label: @getLabel(@model)
          manifestations: []

        @finishTree()
      when 'av_manifestation', 'nonav_manifestation'
        @createBasicTreeForManifestation()
      when 'item'
        @createBasicTreeForItem()
      else
        console.warn('SubType', @model.subType, 'not recognized in object summary')

  getTemplateData: ->
    {
      tree: @creationTree
      isChild: utils.isChildWindow()
    }

  getLabel: (model, index, maxChars = 40) ->
    findDateOfProduction = (model) ->
      dates = model.get('vhh_Date')
      return null unless dates?

      for date in dates
        if date.date_Type?.data == 2038     # Date of production
          return date.date_Date.label.replace('/', " #{lang._('label.to')} ")

      return null

    tryToAddLabel = (list, model, attrKey, subKey, subKeyAlt, maxChars = 40) ->
      attr = model.get(attrKey)
      return unless attr?.length > 0

      attr = attr[0]
      
      if attr[subKey]?.label?
        list.push(_.truncate(attr[subKey].label, { length: maxChars }))

      else if subKeyAlt? and attr[subKeyAlt]?.label?
        list.push(_.truncate(attr[subKeyAlt].label, { length: maxChars }))

    typeLabel = null

    switch model.subType
      when 'av_creation', 'nonav_creation'
        typeLabel = lang._("label.#{model.subType}")
        label = _.truncate model.getPreferredLabel(),
          length: maxChars

        dateOfProduction = findDateOfProduction(model)
        if dateOfProduction?
          label += " (#{dateOfProduction})"

      when 'av_manifestation'
        typeLabel = lang._("label.#{model.subType}") + ' ' + index
        labels = []
        relatedObjects = model.get('related')?.ca_objects

        tryToAddLabel(labels, model, 'vhh_VariantType', 'VT_List', 'VT_Text', maxChars)
        tryToAddLabel(labels, model, 'vhh_CarrierType2', 'CarrierTypeList', 'CarrierTypeText', maxChars)
        tryToAddLabel(labels, model, 'vhh_Gauge', 'Gauge_List', 'Gauge_Text', maxChars)

        if relatedObjects?.length > 0
          for relation in relatedObjects
            if relation.relationship_type_code == 'isderivativeofavm' and relation.direction == 'ltor'
              labels.push(lang._('label.derivative'))

        if labels.length > 0
          label = labels.join(' / ')
        else
          label = '-'

      when 'nonav_manifestation'
        typeLabel = lang._("label.#{model.subType}") + ' ' + index
        labels = []
        
        tryToAddLabel(labels, model, 'vhh_VariantType', 'VT_List', 'VT_Text', maxChars)
        tryToAddLabel(labels, model, 'vhh_CarrierType2', 'CarrierTypeList', 'CarrierTypeText', maxChars)
        
        if labels.length > 0
          label = labels.join(' / ')
        else
          label = '-'

      when 'item'
        typeLabel = lang._("label.#{model.subType}") + ' ' + index

        labels = []
        
        switch model.getMediaType()
          when 'image'
            labels.push("<i class=\"fa fa-image\"></i> #{lang._('label.media_types.image')}")

          when 'video'
            labels.push("<i class=\"fa fa-video\"></i> #{lang._('label.video')}")

        tryToAddLabel(labels, model, 'vhh_ControllingEntity', 'CE_Agent', maxChars)
        tryToAddLabel(labels, model, 'vhh_HoldingInstitution', 'vhh_HoldingInstitution', maxChars)

        if labels.length > 0
          label = labels.join(' / ')
        else
          label = '-'

    html = []
    if typeLabel?
      html.push("<div class=\"summary-object-type-label\">#{typeLabel}</div>")

    html.push("<div class=\"summary-object-label\">#{label}</div>")
    html.join('')


  createBasicTreeForManifestation: ->
    @creationTree =
      model: null
      manifestations: [{
        model: @model
        thumb: @model.getPrimaryThumbUrl()
        label: @getLabel(@model, 1)
        items: []
      }]

    creationId = @model.getParentId()
    if creationId?
      creation = new CaObject id: creationId
      creation.fetch
        success: (model) =>
          @modelsById[model.id] = model
          @creationTree.model = model
          @creationTree.label = @getLabel(model, 1, 80)
          @finishTree()

        error: =>
          console.warn 'Error while fetching creation'
          @finishTree()

  createBasicTreeForItem: ->
    @creationTree =
      model: null
      manifestations: [{
        model: null
        items: [{
          label: @getLabel(@model, 1, 80)
          thumb: @model.getPrimaryThumbUrl()
          selected: true
          model: @model
        }]
      }]

    manifestationId = @model.getParentId()
    
    if manifestationId?
      manifestation = new CaObject id: manifestationId
      manifestation.fetch
        success: =>
          @modelsById[manifestation.id] = manifestation
          @creationTree.manifestations[0].model = manifestation
          @creationTree.manifestations[0].thumb = manifestation.getPrimaryThumbUrl()
          @creationTree.manifestations[0].label = @getLabel(manifestation, 1)
          creationId = manifestation.getParentId()
          
          if creationId?
            creation = new CaObject id: creationId
            creation.fetch
              success: =>
                @modelsById[creation.id] = creation
                @creationTree.model = creation
                @creationTree.label = @getLabel(creation, 1, 80)
                @finishTree()

              error: =>
                console.warn 'Error while fetching creation'
                @finishTree()

        error: =>
          console.warn 'Error while fetching manifestation'
          @finishTree()

    else
      @finishTree()

  finishTree: ->
    @manifestationFetchCount = 0
    @itemFetchCount = null

    if @creationTree.model?
      manifestationIds = @creationTree.model.getChildrenIds()
      @manifestationFetchCount = manifestationIds.length

      for manifestationId in manifestationIds
        manifestationObject = _.find @creationTree.manifestations, (object) ->#
          "#{object.model.id}" == manifestationId

        if manifestationObject?
          @manifestationFetchCount--
          @finishTreeForManifestation(manifestationObject)

        else
          manifestation = new CaObject id: manifestationId
          manifestation.fetch
            success: (model) =>
              @manifestationFetchCount--
              @modelsById[model.id] = model
              manifestationObject = 
                model: model
                thumb: model.getPrimaryThumbUrl()
                label: @getLabel(model, @creationTree.manifestations.length + 1, 40)
                items: []

              @creationTree.manifestations.push(manifestationObject)
              @finishTreeForManifestation(manifestationObject)
            error: =>
              @manifestationFetchCount--
              @checkIfTreeFinished()
              console.warn 'Error while fetching manifestation for creation'

    else
      @checkIfTreeFinished()

  finishTreeForManifestation: (manifestationObject) ->
    itemIds = manifestationObject.model.getChildrenIds()
    itemIds = _.without(itemIds, "#{@model.id}")

    for itemId in itemIds
      item = _.find manifestationObject.items, (object) ->
        object.id == itemId

      unless item?
        item = new CaObject id: itemId
        @itemFetchCount = 0 unless @itemFetchCount?
        @itemFetchCount++
        item.fetch
          success: (model) =>
            @itemFetchCount--
            @modelsById[model.id] = model
            model.parentObject.items.push
              label: @getLabel(model, model.parentObject.items.length + 1, 40)
              thumb: model.getPrimaryThumbUrl()
              model: model

            @checkIfTreeFinished()

          error: =>
            @itemFetchCount--
            @checkIfTreeFinished()
            console.warn 'Error while fetching item for manifestation'

      item.parentObject = manifestationObject
  
    @checkIfTreeFinished()

  checkIfTreeFinished: ->
    return if @manifestationFetchCount > 0 or (@itemFetchCount? and @itemFetchCount > 0)

    @sortAndLabelTree()
    @render()

    @$content = @$el.find('.summary-content')
    @$nav = @$el.find('.summary-navigation')

    @showSummary(@model)

  sortAndLabelTree: ->
    if @creationTree.manifestations?.length > 0
      @creationTree.manifestations = _.sortBy @creationTree.manifestations,
        (manifestation) ->
          manifestation.model?.id

      for manifestation, index in @creationTree.manifestations
        if manifestation.model?
          manifestation.label = @getLabel(manifestation.model, index + 1, 40)

        if manifestation.items?.length > 0
          manifestation.items = _.sortBy manifestation.items,
            (item) ->
              item.model?.id

          for item, itemIndex in manifestation.items
            if item.model?
              item.label = @getLabel(item.model, itemIndex + 1, 40)

  showSummary: (model) ->
    if @summaryViews?
      for summaryView in @summaryViews
        summaryView.remove()

    @summaryViews = []
    @$content.empty()
    list = @createListForModel(model)

    $('html').scrollTop(0)
    
    for listItem in list
      @$content.append @itemTemplate
        headerId: "summary-object-header-#{listItem.model.id}"
        bodyId: "summary-object-body-#{listItem.model.id}"
        label: listItem.label
        open: listItem.open
        className: listItem.className

    for listItem in list
      $node = @$content.find("#summary-object-body-#{listItem.model.id}").find('.card-body')
      $navItem = @$nav.find(".summary-nav-item[data-id=\"#{listItem.model.id}\"]")
      $navItem.addClass('active')
      $navItem.toggleClass('selected', listItem.model.id == model.id)

      summaryView  = new DetailSummaryView
        container: $node
        model: listItem.model
        parent: @
        definitions: listItem.model.createAttrGroupsForSummaries()

      @summaryViews.push(summaryView)
      @subview("summary-#{listItem.model.id}", summaryView)

    @scrollTo(@$content.find("#summary-object-body-#{model.id}").parent(), 11)

  createListForModel: (model) ->
    list = []

    if @creationTree.model?
      list.push
        model: @creationTree.model
        label: @getLabel(@creationTree.model, itemIndex, 160)
        open: @creationTree.model.id == model.id
        className: 'object-creation'

    for manifestation, manifestationIndex in @creationTree.manifestations
      if model.id == manifestation.model?.id or model.id == @creationTree.model?.id
        list.push
          model: manifestation.model
          label: @getLabel(manifestation.model, manifestationIndex + 1, 80)
          open: model.id == manifestation.model.id
          className: 'object-manifestation'

        for item, itemIndex in manifestation.items
          list.push
            model: item.model
            label: @getLabel(item.model, itemIndex + 1, 80)
            open: false
            className: 'object-item'

      else
        for item, itemIndex in manifestation.items
          if item.model.id == model.id
            if manifestation.model?
              list.push
                model: manifestation.model
                label: @getLabel(manifestation.model, manifestationIndex + 1, 80)
                open: false
                className: 'object-manifestation'

            list.push
              model: item.model
              label: @getLabel(item.model, itemIndex + 1, 80)
              open: true
              className: 'object-item'

    list

  clickNavItem: (event) ->
    $target = $(event.currentTarget)
    id = $target.parent().data('id')
    return unless _.has(@modelsById, id)

    @$nav.find('.active').removeClass('active')
    @$nav.find('.selected').removeClass('selected')

    model = @modelsById[id]
    @showSummary(model)

    @parentView.setPageTitle(model)

  switchToEditMode: (model) ->
    if model.id == @model.id
      @parentView?.switchToEditMode()

    else
      Chaplin.utils.redirectTo('details#objectTab', id: model.id, tab: 'basic')

  showMediaOverlay: (model) ->
    @parentView?.showMediaOverlay(model)

















