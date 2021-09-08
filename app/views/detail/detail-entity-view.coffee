CaEntity              = require 'models/ca-entity'
DetailView            = require 'views/detail/detail-view'

module.exports = class DetailEntityView extends DetailView
  createRoute: 'create#agent'
  deleteLabel: 'button.delete_agent'
  parentBreadcrumb:
    label: 'breadcrumbs.agents'
    route: 'search#agents'

  initialize: (data) ->
    @model = new CaEntity id: data.id
    super(data)