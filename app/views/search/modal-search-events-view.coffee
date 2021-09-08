utils           = require 'lib/utils'
CaOccurrences   = require 'models/ca-occurrences'
ModalSearchView = require './modal-search-view'

module.exports = class ModalSearchEventsView extends ModalSearchView
  collectionClass: CaOccurrences
  placeholder: 'placeholder.search_events'
  labelKey: 'display_label'
  showTypeFilter: true

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
