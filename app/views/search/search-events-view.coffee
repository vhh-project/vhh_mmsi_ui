utils             = require 'lib/utils'
CaOccurrences     = require 'models/ca-occurrences'
SearchView        = require './search-view'

module.exports = class SearchEventsView extends SearchView
  collectionClass: CaOccurrences
  tableRoute: 'details#event'
  createRoute: 'create#event'
  placeholder: 'placeholder.search_events'
  langKeys:
    breadcrumbsTitle: 'title.search_results'
    breadcrumbsPath: 'breadcrumbs.events'
    foundItems: 'title.events_found'

  getTableColumns: ->
    [
      { name: '#', className: 'text-right', attr: (model, index) => @getTableIndex(index) }
      { name: lang._('table.idno'), attr: 'idno' }
      {
        name: lang._('table.preferred_label')
        attr: (model) ->
          titles = model.get('ca_occurrences.preferred_labels', false)
          titles = [] unless titles?.length
          utils.escape(titles).join('<br />')
        sortCriteria: 'ca_occurrences.preferred_labels'
      }
      {
        name: lang._('table.date')
        attr: (model) ->
          model.getAttrValue('ca_occurrences.vhh_DateEvent', 0)
        sortCriteria: 'ca_occurrences.vhh_DateEvent'
      }
      {
        name: lang._('table.object_type')
        attr: (model) =>
          @getObjectTypeLabel(model.get('ca_occurrences.type_id', false))
        sortCriteria: 'ca_occurrences.type_id'
      }
    ]