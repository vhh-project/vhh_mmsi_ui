CaBaseCollection  = require './ca-base-collection'
CaPlace           = require './ca-place'

module.exports = class CaPlaces extends CaBaseCollection
  detailModel       : CaPlace
  objectType        : 'ca_places'

  bundles:
    'ca_places.type_id':
      returnAsArray: false
    'ca_places.preferred_labels':
      returnAsArray: true