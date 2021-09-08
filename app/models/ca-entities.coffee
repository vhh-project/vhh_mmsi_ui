CaBaseCollection  = require './ca-base-collection'
CaEntity          = require './ca-entity'

module.exports = class CaEntities extends CaBaseCollection
  detailModel       : CaEntity
  objectType        : 'ca_entities'

  bundles:
    'ca_object_representations.media.preview170':
      returnURL: true
    'ca_entities.preferred_labels':
      returnAsArray: true
    'ca_entities.type_id':
      returnAsArray: false
    'ca_entities.vhh_Date':
      returnAsArray: true