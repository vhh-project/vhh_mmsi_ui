CaBaseCollection  = require './ca-base-collection'
CaCollection      = require './ca-collection'

module.exports = class CaCollections extends CaBaseCollection
  detailModel       : CaCollection
  objectType        : 'ca_collections'

  bundles:
    'ca_collections.type_id':
      returnAsArray: false
    'ca_collections.preferred_labels':
      returnAsArray: true