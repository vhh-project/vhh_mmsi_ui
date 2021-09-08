CaBaseModel = require './ca-base-model'

module.exports = class CaEntity extends CaBaseModel
  objectType  : 'ca_entities'
  labelKey    : 'label.agent'

  getIdFromReponse: (response) ->
    response.entity_id or null