CaBaseCollection  = require './ca-base-collection'
CaPlace           = require './ca-place'

module.exports = class CaPlacesMap extends CaBaseCollection
  PAGE_COUNT: 500

  detailModel       : CaPlace
  objectType        : 'ca_places'
  geoBounds         : null
  comparator        : 'ca_places.preferred_labels'

  bundles:
    'ca_places.type_id':
      returnAsArray: false
    'ca_places.preferred_labels':
      returnAsArray: false
    'ca_places.georeference':
      returnAsArray: true
    'ca_objects.object_id':
      returnAsArray: true
    'ca_entities.entity_id':
      returnAsArray: true
    'ca_occurrences.occurrence_id':
      returnAsArray: true
    'ca_places.related.place_id':
      returnAsArray: true
    'ca_collections.collection_id':
      returnAsArray: true

  queryHook: (query) ->
    return unless @geoBounds?
    query.push("ca_places.georeference:\"[#{@geoBounds._northEast.lat}, #{@geoBounds._northEast.lng} to #{@geoBounds._southWest.lat}, #{@geoBounds._southWest.lng}]\"")