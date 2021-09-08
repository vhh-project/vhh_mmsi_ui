utils             = require 'lib/utils'
CaEntities        = require 'models/ca-entities'
SearchView        = require './search-view'

module.exports = class SearchAgentsView extends SearchView
  collectionClass: CaEntities
  tableRoute: 'details#agent'
  createRoute: 'create#agent'
  placeholder: 'placeholder.search_agents'
  langKeys:
    breadcrumbsTitle: 'title.search_results'
    breadcrumbsPath: 'breadcrumbs.agents'
    foundItems: 'title.agents_found'

  getTableColumns: ->
    [
      { name: '#', className: 'text-right', attr: (model, index) => @getTableIndex(index) }
      {
        name: lang._('table.thumbnail'),
        className: 'thumb'
        attr: (model, index) ->
          previewUrl = model.getPreview170()
          
          if previewUrl?
            "<div class=\"thumb\" style=\"background-image: url(#{previewUrl});\">"
          else
            '&nbsp;'
      }
      { name: lang._('table.idno'), attr: 'idno' }
      {
        name: lang._('table.preferred_label')
        attr: (model) ->
          titles = model.get('ca_entities.preferred_labels', false)
          titles = [] unless titles?.length
          utils.escape(titles).join('<br />')
        sortCriteria: 'ca_entities.preferred_labels'
      }
      {
        name: lang._('table.date_of_birth_or_foundation')
        attr: (model) ->
          model.getAttrValue('ca_occurrences.vhh_DateEvent', 0, 1, ['2026', '2029'])

      }
      {
        name: lang._('table.date_of_death_or_dissolution')
        attr: (model) ->
          model.getAttrValue('ca_entities.vhh_Date', 0, 1, ['2027', '2031'])

      }
      {
        name: lang._('table.object_type')
        attr: (model) =>
          @getObjectTypeLabel(model.get('ca_entities.type_id', false))
        sortCriteria: 'ca_entities.type_id'
      }
    ]