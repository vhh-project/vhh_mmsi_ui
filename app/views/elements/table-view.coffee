View = require 'views/base/view'

module.exports = class TableView extends View
  autoRender: false
  className: 'table'
  tagName: 'table'
  
  columns: null
  collection: null
  dragCallback: null
  
  events:
    'click .sortable': 'clickSort'
    'click .link-row td:not(.no-link)': 'clickLinkCell'
    'mouseover .link-row': 'hoverLinkRow'
    'mouseout .link-row': 'outLinkRow'
  
  initialize: (data) ->
    super(data)
    
    @collection = data.collection
    @columns = data.columns
    
    @className = data.className if data.className?

    @clickCallback = data.clickCallback if data.clickCallback?
    @hoverCallback = data.hoverCallback
    @rowCallback = data.rowCallback if data.rowCallback?
    @rowClassCallback = data.rowClassCallback if data.rowClassCallback?
    @renderedCallback = data.renderedCallback if data.renderedCallback?
    @noHeader = data.noHeader? and data.noHeader
    @stickyHeader = data.stickyHeader == true
    @stickyAddMaskAbove = if data.addMaskAbove? then data.addMaskAbove else true
    @stickyScrollTarget = data.stickyScrollTarget or window
    @parentView = data.parent
    
    # Hack to prevent awkward empty table sometimes
    window.setTimeout(
      => 
        @render()
      , 1
    )
    
  render: ->
    if @clickCallback?
      @$el.addClass 'table-hover'
    
    html = ''
    
    unless @noHeader
      html += '<thead><tr>'
      
      for column in @columns
        name = column.name
        html += @drawCell column, name, true
        
      html += '</tr></thead>'
    
    html += '<tbody></tbody>'
      
    @$el.html html

    window.setTimeout(@rendered, 10)
    
  rendered: =>
    @redraw()

    if @noHeader
      @$el.addClass 'no-header' 

    else if @stickyHeader
      @stickyInitialTop = @$el.offset().top
      $(@stickyScrollTarget).on 'scroll', @scrollSticky
      $(window).on 'resize', @resizeSticky

    @renderedCallback() if @renderedCallback?

  scrollSticky: (forceUnsticky = false) =>
    $thead = @$el.find('thead:first')
    tableTop = @$el.offset().top
    tableBottom = tableTop + @$el.height()

    if forceUnsticky == true or tableTop > @stickyInitialTop or tableBottom - $thead.height() <= 0
      if $thead.css('position') == 'fixed'
        $thead.remove()

        @$el.siblings('.sticky-table-mask').remove()

        @$el.find('td').css
          width: ''
          height: ''

    else if tableTop <= @stickyInitialTop and $thead.css('position') != 'fixed'
      $thead.clone().appendTo(@$el)
      @$el.find('tbody').css('t-index', 1)

      dimensions = []

      $thead.find('th').each (thIndex, th) ->
        $th = $(th)

        dimensions.push
          width: $th.outerWidth()
          height: $th.outerHeight()

      for dimension, index in dimensions
        @$el.find("th:nth-child(#{index + 1})").attr('style', "width: #{dimension.width}px !important; height: #{dimension.height}px !important;")

      left = $thead.offset().left

      $thead.css
        position: 'fixed'
        top: "#{@stickyInitialTop}px"
        left: "#{left}px"
        'z-index': 3

      if @stickyAddMaskAbove
        @$el.before("<div class=\"sticky-table-mask\" style=\"background-color: #fff; position: fixed; top: 0; left: #{left}px; height: #{@stickyInitialTop}px; width: #{@$el.width()}px;\"></div>")

  resizeSticky: =>
    return unless @stickyHeader
    @scrollSticky(true)
    
  redraw: ->
    @drawCells()
    @updateHeader()

    if @blinkIdForRedraw?
      @blinkById @blinkIdForRedraw
      delete @blinkIdForRedraw
    
  drawCells: ->
    unless @collection?.length > 0
      html = "<tr><td class=\"text-center text-muted\" colspan=\"#{@columns.length}\"><em>No entries</em></td></tr>"
    else  
      html = ''
      
      for model, index in @collection.models
        html += '<tr'
        classNames = []
        
        if @clickCallback?   
          classNames.push('link-row')

        if @rowClassCallback?
          classNames.push(@rowClassCallback(model))

        if classNames.length > 0
          html += " class=\"#{classNames.join(' ')}\""

        if model.id?
          html += " data-id=\"#{model.id}\""

        html += '>'
        
        for column in @columns
          html += @drawCell column, @formatCell(model, column, index)
          
        html += '</tr>'
      
    @$el.find('tbody').html html

  drawCell: (column, content, isHeader = false) ->
    if isHeader == true
      if @headerColSpan?
        @headerColSpan--

        return if @headerColSpan > 0
        delete @headerColSpan

    classes = []
    classes.push 'sortable' if isHeader and column.sortCriteria?
    classes.push 'no-select' if isHeader
    classes.push 'checkbox' if column.checkbox
    
    if isHeader == true
      html = '<th'

      if column.headerColSpan?
        @headerColSpan = Number column.headerColSpan
        html += " colspan=\"#{column.headerColSpan}\""

      else
        classes.push column.className if column.className?

      if column.sortCriteria?
        html += " data-sort=\"#{column.sortCriteria}\""
        html += " data-direction=\"#{if column.sortDirection? then column.sortDirection else 'asc'}\""

    else
      html = '<td'
      classes.push column.className if column.className?
    
    html += " class=\"#{classes.join ' '}\"" if classes.length > 0
    html += " style=\"#{column.style}\"" if column.style?
    html += '>'
    
    if column.checkbox
      html += '<div></div>'
    else
      html += if content? then content else '&nbsp'
      
    html += if isHeader then '</th>' else '</td>'

  getCollection: -> @collection
          
  clickSort: (event) ->
    target = $(event.currentTarget)

    sortCriteria = target.data('sort')
    sortDirection = target.data('direction')

    if sortCriteria == @collection.sortCriteria
      @collection.sortDirection = if @collection.sortDirection == 'desc' then 'asc' else 'desc'

    else 
      @collection.sortCriteria = sortCriteria
      @collection.sortDirection = sortDirection
    
    @parentView?.onToggleSortCriteria()
    @updateHeader()
    
  updateHeader: ->
    @$el.find('thead > tr > th')
      .removeClass('sort-asc')
      .removeClass('sort-desc')
      
    return unless @collection?.length > 0
    
    $object = @$el.find "thead > tr > th[data-sort=\"#{@collection.sortCriteria}\"]"
    $object.addClass if @collection.sortDirection == 'asc' then 'sort-asc' else 'sort-desc'
    $object.data('direction', @collection.sortDirection)
  
  clickLinkCell: (event) ->
    $target = $(event.currentTarget)
    $row = $target.parent() 
    id = $row.data('id')
    openInNewTab = (event.wich == 2) or (event.which == 1 && (event.ctrlKey or event.metaKey))
    @clickCallback $row, id, @collection.get(id), openInNewTab

  hoverLinkRow: (event) ->
    return unless @hoverCallback?

    @hoverCallback $(event.currentTarget).data('id'), true

  outLinkRow: (event) ->
    return unless @hoverCallback?

    @hoverCallback $(event.currentTarget).data('id'), false

  blinkById: (id, waitForRedraw = false) ->
    if waitForRedraw == true
      @blinkIdForRedraw = id
      return 

    @blinkTableRowById @$el, id
  
  formatCell: (model, cell, index) ->
    if cell.call?
      result = model[cell.call]?.apply model, cell.callParams or []
      result = '' unless result?
    
    else if typeof cell.attr == 'function'
      result = cell.attr model, index, cell
      result = '' unless result?

    else
      result = model.getf(cell.attr, cell.lang)
      result = '' unless result?

      if typeof result == 'string'
        split = result.split '<br />'
        split = _.map split, (item) -> Handlebars.Utils.escapeExpression item
        result = split.join '<br />'

    if cell.lang and _.isObject(result)
      langCode = if typeof cell.lang == 'string' then cell.lang else lang.code

      result = result[langCode] or ''

    result = cell.before + result if cell.before?      
    result += cell.after if cell.after?

    "#{result}"

  remove: ->
    if @stickyHeader
      $(@stickyScrollTarget).off 'scroll', @scrollSticky
      $(window).off 'resize', @resizeSticky

    super()