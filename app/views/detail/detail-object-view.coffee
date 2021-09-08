CaObject              = require 'models/ca-object'
DetailView            = require 'views/detail/detail-view'

module.exports = class DetailObjectView extends DetailView
  createRoute: 'create#object'
  deleteLabel: 'button.delete_object'
  parentBreadcrumb:
    label: 'breadcrumbs.objects'
    route: 'search#objects'

  initialize: (data) ->
    @model = new CaObject id: data.id
    super(data)