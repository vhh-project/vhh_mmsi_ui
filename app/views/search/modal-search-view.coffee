CaBaseCollection  = require 'models/ca-base-collection'
ObjectDefinitions = require 'models/object-definitions'
ModalView         = require 'views/elements/modal-view'
TableView         = require 'views/elements/table-view'
PagingView        = require 'views/elements/paging-view'

module.exports = class ModalSearchView extends ModalView
  autoRender: false
  collectionClass: CaBaseCollection

  listen:
    'sync collection': 'syncCollection'

  events:
    'click .button-select': 'clickSelect'
    'submit form': 'startSearch'
    'change #modal-filter-select-object-type': 'changeObjectType'

  placeholder: 'placeholder.search'
  selectLangKey: 'button.select'
  labelKey: 'idno'
  showTypeFilter: false

  initialize: (data) ->
    super(data)
    
    @collection = new @collectionClass

    @_data.html = true
    @_data.noButtons = true
    @_data.large = true
    @_data.autofocus = '.search-input-input'

    if @showTypeFilter
      @collection.loadCaDefinition => 
        @_data.content = require('./templates/modal-search')({
          placeholder: @placeholder
          objectGroup: @getObjectGroup()
        })

        @render()

    else
      @_data.content = require('./templates/modal-search')({
        placeholder: @placeholder
      })

      @render()

  attach: ->
    super()

    @$searchInput = @$el.find('.search-input-input')
    @$tableContainer = @$el.find('.table-container')
    @fetch()

  fetch: ->
    @collection.fetch()
    @addSpinner(@$tableContainer)

  syncCollection: ->
    @removeSpinner(@$tableContainer)
    @tableView?.remove()

    selectCol =
      attr: (model) =>
        "<button type=\"button\" class=\"btn btn-primary btn-sm button-select\" data-id=\"#{model.id}\">#{lang._(@selectLangKey)}</button>"

    columns = @getTableColumns() or []
    columns.unshift(selectCol)

    @tableView = new TableView
      parent: @
      className: 'table table-media'
      collection: @collection
      container: @$tableContainer
      columns: columns
      clickCallback: @clickCallback

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

  getTableIndex: (index) ->
    ((@collection.page - 1) * @collection.PAGE_COUNT) + index + 1

  getObjectTypeLabel: (typeId) ->
    lang._(ObjectDefinitions.getObjectTypeLabel(typeId))

  startSearch: (event) =>
    event.preventDefault()
    value = $.trim(@$searchInput.val())

    @collection.page = 1
    @collection.query = if value.length > 0 then value else null
    @fetch()

  pagingChanged: (index) =>
    @collection.page = index
    @fetch()

  clickSelect: (event) ->
    id = event.currentTarget.dataset.id
    label = @collection.get(id)?.get(@labelKey)
    detailModel = @collectionClass.prototype.detailModel.prototype
    typeId = @collection.get(id).get("#{detailModel.objectType}.type_id", false)
    
    @_data.onSelect?(id, label, typeId)
    @$modal.modal('hide')

  onToggleSortCriteria: () ->
    @fetch()

  getObjectGroup: ->
    return null unless @showTypeFilter

    objectGroup = _.map ObjectDefinitions.getObjectGroup(@collection.objectType), (item, key) ->
      {
        key: key
        typeId: item.typeId
        label: lang._(item.label)
      }

    _.sortBy(objectGroup, 'label')

  changeObjectType: (event) ->
    value = $(event.currentTarget).val()
    @collection.typeId = if value.length > 0 then value else null
    @fetch()