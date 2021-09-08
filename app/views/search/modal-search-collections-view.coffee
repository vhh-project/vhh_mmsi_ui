utils           = require 'lib/utils'
CaCollections   = require 'models/ca-collections'
ModalSearchView = require './modal-search-view'

module.exports = class ModalSearchCollectionsView extends ModalSearchView
  collectionClass: CaCollections
  placeholder: 'placeholder.search_collections'
  labelKey: 'display_label'
  showTypeFilter: false

  getTableColumns: ->
    [
      { name: '#', className: 'text-right', attr: (model, index) => @getTableIndex(index) }
      { name: lang._('table.idno'), attr: 'idno' }
      {
        name: lang._('table.preferred_label')
        attr: (model) ->
          titles = model.get('ca_collections.preferred_labels', false)
          titles = [] unless titles?.length
          utils.escape(titles).join('<br />')
        sortCriteria: 'ca_collections.preferred_labels'
      }
      {
        name: lang._('table.object_type')
        attr: (model) =>
          @getObjectTypeLabel(model.get('ca_collections.type_id', false))
        sortCriteria: 'ca_collections.type_id'
      }
    ]
