CaBaseModel = require './ca-base-model'

module.exports = class CaCollection extends CaBaseModel
  objectType  : 'ca_collections'
  labelKey    : 'label.collection'

  getIdFromReponse: (response) ->
    response.collection_id or null