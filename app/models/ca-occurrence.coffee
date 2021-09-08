CaBaseModel = require './ca-base-model'

module.exports = class CaOccurrence extends CaBaseModel
  objectType: 'ca_occurrences'
  labelKey: 'label.event'

  getIdFromReponse: (response) ->
    response.occurrence_id or null