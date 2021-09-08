CaBaseModel = require './ca-base-model'

module.exports = class CaPlace extends CaBaseModel
  objectType  : 'ca_places'
  labelKey    : 'label.place'

  getIdFromReponse: (response) ->
    response.place_id or null