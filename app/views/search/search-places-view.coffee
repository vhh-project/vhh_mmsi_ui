utils             = require 'lib/utils'
CaPlaces          = require 'models/ca-places'
SearchView        = require './search-view'

module.exports = class SearchPlacesView extends SearchView
  collectionClass: CaPlaces
  tableRoute: 'details#place'
  createRoute: 'create#place'
  placeholder: 'placeholder.search_places'
  langKeys:
    breadcrumbsTitle: 'title.search_results'
    breadcrumbsPath: 'breadcrumbs.places'
    foundItems: 'title.places_found'
  showTypeFilter: false

  getTableColumns: ->
    [
      { name: '#', className: 'text-right', attr: (model, index) => @getTableIndex(index) }
      { name: lang._('table.idno'), attr: 'idno' }
      {
        name: lang._('table.preferred_label')
        attr: (model) ->
          titles = model.get('ca_places.preferred_labels', false)
          titles = [] unless titles?.length
          utils.escape(titles).join('<br />')
        sortCriteria: 'ca_places.preferred_labels'
      }
      {
        name: lang._('table.object_type')
        attr: (model) =>
          @getObjectTypeLabel(model.get('ca_places.type_id', false))
        sortCriteria: 'ca_places.type_id'
      }
    ]