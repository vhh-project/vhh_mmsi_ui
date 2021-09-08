CaPlace     = require 'models/ca-place'
DetailView  = require 'views/detail/detail-view'

module.exports = class DetailPlaceView extends DetailView
  createRoute: 'create#place'
  deleteLabel: 'button.delete_place'
  parentBreadcrumb:
    label: 'breadcrumbs.places'
    route: 'search#places'

  initialize: (data) ->
    @model = new CaPlace id: data.id
    super(data)