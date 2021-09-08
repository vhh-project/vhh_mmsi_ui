utils               = require 'lib/utils'
Chaplin             = require 'chaplin'
CaBaseCollection    = require 'models/ca-base-collection'
ObjectDefinitions   = require 'models/object-definitions'

View                = require 'views/base/view'
BreadcrumbsView     = require 'views/elements/breadcrumbs-view'
SearchInputView     = require './search-input-view'
CreateDropdownView  = require 'views/elements/create-dropdown-view'
TableView           = require 'views/elements/table-view'
PagingView          = require 'views/elements/paging-view'

module.exports = class SearchView extends View
  @savedCollections: []
  @savedQueryText: null

  bodyClass: 'search'

  settings:
    showFilters: 'no'
 
  autoRender: false
  className: 'search-view'
  template: require './templates/search'
  placeholder: 'placeholder.search'
  rowClassCallback: null

  showTypeFilter: true

  collectionClass: CaBaseCollection
  tableRoute: 'details#object'
  langKeys:
    breadcrumbsTitle: 'title.search_results'
    breadcrumbsPath: 'breadcrumbs.objects'
    foundItems: 'title.objects_found'

  listen: 
    'sync collection': 'syncCollection'

  events:
    'change #switch-advanced-search': 'changeAdvancedSearch'
    'change #filter-select-object-type': 'changeObjectType'
    'change #filter-select-user-edited': 'changeUserEdited'
    'change #filter-select-edited-period': 'changePeriod'

  initialize: ->
    super()

    unless SearchView.savedCollections[@collectionClass::objectType]?
      SearchView.savedCollections[@collectionClass::objectType] = new @collectionClass
      
    @collection = SearchView.savedCollections[@collectionClass::objectType]
    
    @collection.page = 1 if @collection.query != SearchView.savedQueryText
    @collection.query = SearchView.savedQueryText

    $(window).on('resize', @resize)

    @collection.loadCaDefinition => @render()

  getTemplateData: ->
    if @showTypeFilter
      objectGroup = _.map ObjectDefinitions.getObjectGroup(@collection.objectType), (item, key) ->
        {
          key: key
          typeId: item.typeId
          label: lang._(item.label)
        }

      objectGroup = _.sortBy(objectGroup, 'label')

    {
      collection: @collection
      showFilters: @settings.showFilters
      objectGroup: objectGroup
      editedTypes: [
        { key: 'created', label: 'label.created_by_me' }
        { key: 'modified', label: 'label.modified_by_me' }
      ]
      periodTypes: [
        { key: 'today', label: 'label.today' }
        { key: 'yesterday', label: 'label.yesterday' }
        { key: 'this_month', label: 'label.this_month' }
        { key: 'last_month', label: 'label.last_month' }
      ]
    }

  attach: ->
    super()

    @$filterWrapper = @$el.find('.filter-wrapper')
    @$tableContainer = @$el.find('.table-container')
    @$breadcrumbsContainer = @$el.find('.breadcrumbs-container')

    @searchInputView = new SearchInputView
      query: @collection.query
      container: @$el.find('.search-bar-wrapper')
      className: 'search-input-view col'
      onSearch: @startSearch
      placeholder: @placeholder
      showFilters: @settings.showFilters

    @subview 'search-input', @searchInputView

    @breadcrumbsView = new BreadcrumbsView
      container: @$breadcrumbsContainer
      title: lang._(@langKeys.breadcrumbsTitle)
      icon: 'search'
      path: [
        { name: lang._(@langKeys.breadcrumbsPath) }
      ]

    @subview 'breadcrumbs', @breadcrumbsView

    @createDropdownView = new CreateDropdownView
      container: @$breadcrumbsContainer
      objectGroup: ObjectDefinitions.getObjectGroup(@collection.objectType)
      labelKey: @collection.detailModel.prototype.labelKey
      route: @createRoute

    @subview 'create-dropdown', @createDropdownView

    if @filterTemplateBefore?
      @$el.find('.filter-inner-wrapper').prepend(@filterTemplateBefore({collection: @collection}))

    if @filterTemplateAfter?
      @$el.find('.filter-inner-wrapper').append(@filterTemplateAfter({collection: @collection}))

    @fetch(false)
    @resize()
    @adaptRightWidths()

  fetch: (page = 1) ->
    SearchView.savedQueryText = @collection.query

    unless page == false
      @collection.page = page

    @collection.fetch()
    @addSpinner()

  syncCollection: ->
    @removeSpinner()
    $('html').scrollTop(0)
    @tableView?.remove()
    @breadcrumbsView.setTitle("#{lang._(@langKeys.breadcrumbsTitle)} - #{@collection.totalCount} #{lang._(@langKeys.foundItems, @collection.length)}")

    columns = @getTableColumns()

    columns.push
      name: ''
      className: 'column-link no-link'
      attr: (model, index) =>        
        url = Chaplin.utils.reverse(@tableRoute, id: model.id)
        html = "<a class=\"btn btn-primary button-open-link\" title=\"#{lang._('tip.show_details')}\" href=\"#{url}\"><i class=\"fa fa-eye\"></i></a>"

        unless utils.isChildWindow()
          html += ' ' + utils.renderChildLink(url)

        html

    @tableView = new TableView
      parent: @
      className: 'table table-media'
      collection: @collection
      container: @$tableContainer
      stickyHeader: true
      columns: columns
      rowClassCallback: @rowClassCallback
      clickCallback: (row, id, model, openInNewTab) =>
        utils.openRoute(@tableRoute, { id: id }, openInNewTab)

    @subview('table', @tableView)

    @pagingView?.remove()

    if @collection.totalCount > @collection.PAGE_COUNT
      @pagingView = new PagingView
        parent: @
        container: @$el.find('.paging-container')
        totalCount: @collection.totalCount
        perPage: @collection.PAGE_COUNT
        currentPage: @collection.page
        callback: @pagingChanged

      @subview('paging', @pagingView)

  getTableColumns: ->
    [
      { name: 'ID', attr: 'id', className: 'text-right' }
      { name: lang._('table.idno'), attr: 'idno' }
    ]

  getObjectTypeLabel: (typeId) ->
    lang._(ObjectDefinitions.getObjectTypeLabel(typeId))

  getTableIndex: (index) ->
    ((@collection.page - 1) * @collection.PAGE_COUNT) + index + 1

  startSearch: (value) =>
    @collection.query = if value.length > 0 then value else null
    @fetch()

  pagingChanged: (index) =>
    @fetch(index)

  resize: =>
    return unless @$tableContainer?
    @$tableContainer.css('min-height', '')
    @$tableContainer.css('min-height', $(window).height() - @$tableContainer.offset().top)

  remove: ->
    $(window).off('resize', @resize)
    $('body').css('padding-left', '')
    super()

  adaptRightWidths: =>
    if @$filterWrapper.css('display') == 'block'
      width = "#{@$filterWrapper.width()}px"

    else 
      width = ''
      
    @tableView?.resizeSticky()
    @$breadcrumbsContainer.css left: width
    $('body').css('padding-left', width)

  changeAdvancedSearch: (event) ->
    @$filterWrapper.stop()

    @saveSetting('showFilters', if event.currentTarget.checked then 'yes' else 'no')

    if event.currentTarget.checked
      @$filterWrapper.css(display: 'block')
      @$filterWrapper.css({ width: '' })
      targetWidth = @$filterWrapper.css('width')

      @$filterWrapper.css(width: 0)
      @$filterWrapper.animate { width: targetWidth },
        progress: @adaptRightWidths
        complete: =>
          @tableView?.scrollSticky()

    else
      @$filterWrapper.show()
      
      @$filterWrapper.animate { width: 0 },
        progress: @adaptRightWidths
        complete: =>
          @$filterWrapper.css('display', '')
          $('body').css('padding-left', '')
          @tableView?.scrollSticky()

  changeObjectType: (event) ->
    value = $(event.currentTarget).val()
    @collection.typeId = if value.length > 0 then value else null
    @fetch()

  changeUserEdited: (event) ->
    value = $(event.currentTarget).val()
    @collection.userEdited = if value.length > 0 then value else null
    $('#filter-select-edited-period').toggleClass('d-none', not @collection.userEdited?)

    @fetch()

  changePeriod: (event) ->
    value = $(event.currentTarget).val()
    @collection.editedPeriod = if value.length > 0 then value else null
    @fetch()

  onToggleSortCriteria: ->
    @fetch()