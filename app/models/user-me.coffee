Model = require './base/model'

module.exports = class UserMe extends Model
  url: "#{window.settings.apiUrl}ca/service/user/me"

  parse: (data) ->
    delete data.ok
    data