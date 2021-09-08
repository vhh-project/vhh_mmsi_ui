View = require 'views/base/view'

module.exports = class BreadcrumbsView extends View
  autoRender: true
  className: 'breadcrumbs-view'
  template: require './templates/breadcrumbs'

  showHome: true

  initialize: (data) ->
    super(data)
    
    @title = data.title

    # Used like <i class="fa fa-<iconCode>">
    @iconCode = data.icon
    @path = data.path

    @lastItem = if @path.length? and @path.length > 0 then @path.pop() else null

  attach: ->
    super()

    @$title = @$el.find('.breadcrumbs-title')

  getTemplateData: ->
    {
      showHome: @showHome
      iconCode: @iconCode
      title: @title
      path: @path
      lastItem: @lastItem
    }

  setTitle: (title) ->
    @$title.text(title)