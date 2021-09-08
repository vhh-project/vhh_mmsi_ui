utils           = require 'lib/utils'
CaPlaces        = require 'models/ca-places'
ModalSearchView = require './modal-search-view'

module.exports = class ModalSearchAgentsView extends ModalSearchView
  collectionClass: CaPlaces
  placeholder: 'placeholder.search_places'
  labelKey: 'display_label'

  getTableColumns: ->
    [
      { name: '#', className: 'text-right', attr: (model, index) => @getTableIndex(index) }
      { name: lang._('table.idno'), attr: 'idno', sortCriteria: 'ca_places.idno' }
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
