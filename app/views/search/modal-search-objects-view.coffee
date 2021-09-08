utils             = require 'lib/utils'
CaObjects         = require 'models/ca-objects'
ModalSearchView   = require './modal-search-view'

module.exports = class ModalSearchObjectsView extends ModalSearchView
  collectionClass: CaObjects
  placeholder: 'placeholder.search_objects'
  labelKey: 'display_label'
  showTypeFilter: true

  getTableColumns: ->
    [
      {
        name: '#'
        className: 'text-right'
        attr: (model, index) => @getTableIndex(index)
      }
      { name: lang._('table.idno'), attr: 'idno' }
      {
        name: lang._('table.preferred_label')
        attr: (model) ->
          titles = model.get('ca_objects.preferred_labels', false)
          titles = [] unless titles?.length
          utils.escape(titles).join('<br />')
        sortCriteria: 'ca_objects.preferred_labels'
      }
      {
        name: lang._('table.date_of_production')
        attr: (model) ->
          model.getAttrValue('ca_objects.vhh_Date', 0, 1, '2038')

      }
      {
        name: lang._('table.object_type')
        attr: (model) =>
          @getObjectTypeLabel(model.get('ca_objects.type_id', false))
        sortCriteria: 'ca_objects.type_id'
      }
    ]