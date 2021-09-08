CaBaseCollection  = require './ca-base-collection'
CaOccurrence      = require './ca-occurrence'

module.exports = class CaOccurrences extends CaBaseCollection
  detailModel       : CaOccurrence
  objectType        : 'ca_occurrences'

  bundles:
    'ca_occurrences.type_id':
      returnAsArray: false
    'ca_occurrences.preferred_labels':
      returnAsArray: true
    'ca_occurrences.vhh_DateEvent':
      returnAsArray: true