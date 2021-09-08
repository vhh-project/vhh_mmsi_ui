CaOccurrence  = require 'models/ca-occurrence'
DetailView    = require 'views/detail/detail-view'

module.exports = class DetailEventView extends DetailView
  createRoute: 'create#event'
  deleteLabel: 'button.delete_event'
  parentBreadcrumb:
    label: 'breadcrumbs.events'
    route: 'search#events'

  initialize: (data) ->
    @model = new CaOccurrence id: data.id
    super(data)