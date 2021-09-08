utils                       = require 'lib/utils'
Backbone                    = require 'backbone'
Chaplin                     = require 'chaplin'
View                        = require 'views/base/view'
DetailDataView              = require './data-view'
DetailMediaView             = require './media-view'
DetailShotsView             = require './shots-view'
DetailThumbnailView         = require './thumbnail-view'
DetailRelationsView         = require './relations-view'
DetailSummaryView           = require './summary-view'
DetailSummaryObjectView     = require './summary-object-view'
DetailMediaOverlayView      = require './media-overlay-view'
BreadcrumbsView             = require 'views/elements/breadcrumbs-view'
CreateDropdownView          = require 'views/elements/create-dropdown-view'
ModalView                   = require 'views/elements/modal-view'
ModalSearchObjectsView      = require 'views/search/modal-search-objects-view'
ModalSearchAgentsView       = require 'views/search/modal-search-agents-view'
ModalSearchEventsView       = require 'views/search/modal-search-events-view'
ModalSearchPlacesView       = require 'views/search/modal-search-places-view'
ModalSearchCollectionsView  = require 'views/search/modal-search-collections-view'

module.exports = class DetailView extends View
  autoRender: false
  template: require './templates/detail'
  className: 'detail-view'
  createRoute: 'create#object'
  deleteLabel: 'button.delete_object'
  parentBreadcrumb:
    label: 'breadcrumbs.objects'
    route: 'search#objects'
  canEdit: true
  tabIndex: 0

  events:
    'click #tab-detail .nav-link:not(.dropdown-toggle)': 'changeTab'
    'click .button-delete-record': 'clickDeleteRecord'

  initialize: (data) ->
    super(data)

    @tabName = data.tab
    @tabRoute = data.tabRoute
    @persistedTabs = []

    @model.loadCaDefinition =>
      @model.fetch
        success: =>
          if @model.fetchAdditional?
            @model.fetchAdditional (response) =>
              @render()

          else
            @render()

  getTemplateData: ->
    @objectGroups = @model.getObjectType()
    tabIndex = if @tabName? then @findTabIndex(@tabName) else -1
    @tabIndex = tabIndex if tabIndex > -1

    groups = _.filter @objectGroups.groups, (group) =>
      if group.type == 'shots'
        return @model.hasVideo()

      true

    {
      groups: groups
      tabIndex: @tabIndex
      deleteLabel: @deleteLabel
    }

  setPageTitle: (model) ->
    model = @model unless model?
    idno = model.get('intrinsic_fields.idno')
    utils.setPageTitle(idno, not idno?)

  findTabIndex: (tabName) ->
    for group, index in @objectGroups.groups
      if group.tab == tabName
        return index

    return -1

  attach: ->
    super()

    @setPageTitle()
    @$breadcrumbsContainer = @$el.find('.breadcrumbs-container')
    @breadcrumbsView = new BreadcrumbsView
      container: @$breadcrumbsContainer
      title: @getBreadcrumbTitle()
      icon: @objectGroups.icon
      path: [
        { name: lang._(@parentBreadcrumb.label), href: utils.reverse(@parentBreadcrumb.route)}
        { name: lang._(@objectGroups.label) }
      ]

    @subview 'breadcrumbs', @breadcrumbsView

    @createDropdownView = new CreateDropdownView
      container: @$breadcrumbsContainer
      objectGroup: @model.getObjectGroup()
      labelKey: @model.labelKey
      route: @createRoute

    @subview 'create-dropdown', @createDropdownView

    @$tabs = @$el.find('#tab-detail')
    @$tabContainer = @$el.find('.tab-content')

    @changeTab()

  onUpdated: =>
    @breadcrumbsView.setTitle(@getBreadcrumbTitle())

  changeTab: (event) ->
    if @tabView?
      tab = @findPersistedTab(@tabView)

      if tab?
        @tabView.$el.detach()

      else
        @tabView?.remove()

    if event?
      event.preventDefault()
      @tabIndex = parseInt(event.currentTarget.dataset.index)

    @$tabs.find('.active').removeClass('active')
    @$tabs.find("[data-index=\"#{@tabIndex}\"]").addClass('active')

    url = Chaplin.utils.reverse @tabRoute,
      id: @model.id
      tab: @objectGroups.groups[@tabIndex].tab

    Backbone.history.navigate url.replace(app.router.removeRoot, '/'),
      replace: true

    group = @objectGroups.groups[@tabIndex]

    @$el.toggleClass('show-summary', group.type == 'summary')

    switch group.type
      when 'media'
        tab = @findPersistedTab(@tabIndex)

        if tab?
          @tabView = tab.view
          @$tabContainer.append(@tabView.$el)
          @tabView.notifyReattached?()

        else
          @tabView = new DetailMediaView
            container: @$tabContainer
            model: @model

          @setPersistedTab(@tabIndex, @tabView)

      when 'thumb'
        @tabView = new DetailThumbnailView
          container: @$tabContainer
          model: @model
          canEdit: @canEdit

      when 'relations'
        @tabView = new DetailRelationsView
          container: @$tabContainer
          model: @model
          parent: @
          canEdit: @canEdit
          definitions: @model.createAttrGroupsForDetails(@tabIndex)

      when 'summary'
        if group.subType == 'object'
          @tabView = new DetailSummaryObjectView
            container: @$tabContainer
            model: @model
            parent: @

        else
          @tabView = new DetailSummaryView
            container: @$tabContainer
            model: @model
            parent: @
            definitions: @model.createAttrGroupsForSummaries()

      when 'shots'
        @tabView = new DetailShotsView
          container: @$tabContainer
          model: @model
          parent: @
          canEdit: @canEdit

      else
        @tabView = new DetailDataView
          container: @$tabContainer
          model: @model
          parent: @
          canEdit: @canEdit
          updateCallback: @onUpdated
          definitions: @model.createAttrGroupsForDetails(@tabIndex)

  clickDeleteRecord: ->
    new ModalView
      header: lang._(@deleteLabel)
      content: lang._('message.delete_record')
      confirmText: lang._(@deleteLabel)
      parent: @
      callback: =>
        @addSpinner(@$el)

        @model.deleteRecord (response) =>
          @removeSpinner(@$el)
          if response.success == true
            Chaplin.utils.redirectTo(@parentBreadcrumb.route)

        true

  findPersistedTab: (indexOrView) ->
    if typeof indexOrView == 'number'
      _.find @persistedTabs, (tab) -> tab.index == indexOrView

    else
      _.find @persistedTabs, (tab) ->
        tab.view == indexOrView

  setPersistedTab: (index, tabView) ->
    tab = @findPersistedTab(index)

    if tab?
      tab.view.remove()
      tab.view = tabView

    else
      tab =
        index: index
        view: tabView

      @persistedTabs.push(tab)

  getBreadcrumbTitle: ->
    idno = @model.get('intrinsic_fields.idno')
    title = if idno?.length > 0 then idno else "(#{lang._('label.no_idno')})"

    preferredLabel = @model.getPreferredLabel()
    if preferredLabel?.length > 0
      title += " - #{_.truncate(preferredLabel, length: 80)}"

    title

  startChangeRelation: (objectType, callback) ->
    switch objectType
      when 'ca_objects'
        new ModalSearchObjectsView
          header: lang._('header.change_object')
          parent: @
          onSelect: callback

      when 'ca_entities'
        new ModalSearchAgentsView
          header: lang._('header.change_agent')
          parent: @
          onSelect: callback

      when 'ca_occurrences'
        new ModalSearchEventsView
          header: lang._('header.change_event')
          parent: @
          onSelect: callback

      when 'ca_places'
        new ModalSearchPlacesView
          header: lang._('header.change_place')
          parent: @
          onSelect: callback

      when 'ca_collections'
        new ModalSearchCollectionsView
          header: lang._('header.change_collection')
          parent: @
          onSelect: callback

  switchToEditMode: ->
    @tabIndex = @objectGroups.editTabIndex or 1
    @changeTab()

  showMediaOverlay: (model) ->
    @$el.find('.tab-content').css('display', 'none')

    @overlayView = new DetailMediaOverlayView
      container: @$el
      model: model
      onClose: =>
        @$el.find('.tab-content').css('display', 'block')

    @subview('overlay', @overlayView)

  remove: ->
    if @tabView?
      @tabView?.remove() unless @findPersistedTab(@tabView)

    for tab in @persistedTabs
      tab.view.remove()

    super