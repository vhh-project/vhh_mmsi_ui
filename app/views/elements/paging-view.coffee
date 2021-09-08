View = require 'views/base/view'

module.exports = class PagingView extends View
  autoRender: true
  className: 'paging-view'
  template: require './templates/paging'
  MAX_ITEMS: 10

  events:
    'click .button-paging': 'clickPaging'
    'click .button-next-page': 'clickNextPage'
    'click .button-prev-page': 'clickPrevPage'
    'focus .input-paging-current-page': 'focusPageInput'
    'blur .input-paging-current-page': 'changePageInput'
    'keydown .input-paging-current-page': 'keydownPageInput'

  initialize: (data) ->
    @totalCount = data.totalCount or 0
    @perPage = data.perPage
    @currentPage = data.currentPage
    @callback = data.callback

    super(data)

  getTemplateData: ->
    pages = []
    pageCount = @getPageCount()

    if pageCount > 0
      firstIndex = Math.max(@currentPage - (@MAX_ITEMS / 2), 1)
      lastIndex = Math.min(firstIndex + @MAX_ITEMS, pageCount)

      if firstIndex > 1
        pages.push
          index: 1
          active: 1 == @currentPage

        if firstIndex > 2
          pages.push
            separator: true

      for pageIndex in [firstIndex .. lastIndex]
        pages.push
          index: pageIndex
          active: pageIndex == @currentPage

      if lastIndex < pageCount
        if lastIndex < pageCount - 1
          pages.push
            separator: true

        pages.push
          index: pageCount
          active: pageCount == @currentPage

    {
      pages: pages
      currentPage: @currentPage
      pageCount: pageCount
    }

  getPageCount: ->
    return 0 unless @perPage? and @totalCount?
    pageCount = Math.floor(@totalCount / @perPage)
    pageCount++ if (@totalCount % @perPage) > 0

  clickPaging: (event) ->
    @callback?(parseInt(event.currentTarget.dataset.index))

  clickNextPage: ->
    return if @currentPage >= @getPageCount()
    @callback?(@currentPage + 1)

  clickPrevPage: ->
    return if @currentPage <= 1
    @callback?(@currentPage - 1)

  focusPageInput: (event) ->
    event.currentTarget.select()

  changePageInput: (event) ->
    value = $.trim(event.currentTarget.value)

    if value.length > 0
      pageNumber = parseInt(value)

      if (not isNaN(pageNumber)) and  pageNumber > 0 and pageNumber <= @getPageCount() and pageNumber != @currentPage
        @callback(pageNumber)
        return

    event.currentTarget.value = "#{@currentPage}"

  keydownPageInput: (event) ->
    if event.key == 'Enter'
      $(event.currentTarget).blur()

    else if event.key == 'Escape'
      event.currentTarget.value = "#{@currentPage}"
      $(event.currentTarget).blur()