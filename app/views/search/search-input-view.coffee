View            = require 'views/base/view'

module.exports = class SearchInputView extends View
  autoRender: true
  className: 'search-input-view'
  template: require './templates/search-input'

  events:
    'submit .search-form-main': 'submitForm'
    'click .button-clear-search': 'clickClearSearch'

  initialize: (data) ->
    @onSearch = data.onSearch
    @query = data.query or ''
    @showFilters = data.showFilters
    @placeholder = data.placeholder
    super(data)

  getTemplateData: ->
    query: @query
    showFilters: @showFilters
    placeholder: @placeholder or 'placeholder.search'

  attach: ->
    super()

    @$searchInput = @$el.find('.search-input-input')

  submitForm: (event) ->
    event?.preventDefault()
    value = $.trim(@$searchInput.val())
    @onSearch(value)

  clickClearSearch: ->
    @$searchInput.val('')
    @submitForm()
