CaCollection  = require 'models/ca-collection'
DetailView    = require 'views/detail/detail-view'

module.exports = class DetailCollectionView extends DetailView
  createRoute: 'create#collection'
  deleteLabel: 'button.delete_collection'
  parentBreadcrumb:
    label: 'breadcrumbs.collections'
    route: 'search#collections'

  initialize: (data) ->
    @model = new CaCollection id: data.id
    super(data)