utils             = require 'lib/utils'
CaObjects         = require 'models/ca-objects'
ObjectDefinitions = require 'models/object-definitions'
SearchView        = require './search-view'

module.exports = class SearchObjectsView extends SearchView
  collectionClass: CaObjects
  createRoute: 'create#object'
  placeholder: 'placeholder.search_objects'
  langKeys:
    breadcrumbsTitle: 'title.search_results'
    breadcrumbsPath: 'breadcrumbs.objects'
    foundItems: 'title.objects_found'

  filterTemplateBefore: require './templates/search-objects-filter'

  events:
    'change #filter-select-media': 'changeMedia'

  getTableColumns: ->
    [
      {
        name: '#'
        className: 'text-right'
        attr: (model, index) => @getTableIndex(index)
      }
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

  rowClassCallback: (model) ->
    objectGroup = ObjectDefinitions.getObjectTypeById(model.get('ca_objects.type_id', false))
    objectGroup?.rowClass
     
  changeMedia: (event) ->
    value = $(event.currentTarget).val()

    if value == 'all'
      @collection.mediaType = null

    else
      @collection.mediaType = value

    @fetch()