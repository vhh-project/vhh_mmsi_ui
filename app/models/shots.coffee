Collection = require 'models/base/collection'

module.exports = class Shots extends Collection
  url: -> 
    "#{window.settings.tbaUrl}_search?q=video_id:#{@videoId} AND class_name:shot&sort=in_point:asc&size=5000"

  initialize: (data) ->
    super(data)
    @videoId = data.videoId

  fetch: (options) ->
    options.cache = true
    super(options)

  parse: (data) ->
    _.map data.hits?.hits, (hit) ->
      source = hit._source
      source.id = hit._id
      source

  getList: (isAuto = true) ->
    return null unless @models.length > 0 and @models[0].has('in_point')
    
    list = @filter (model) ->
      if isAuto
        model.get('status') == 'A'

      else
        model.get('status') != 'A'

    _.map list, (model) ->
      {
        id: model.id
        in: model.get('in_point')
        out: model.get('out_point')
        shotType: model.get('value')
        annotator: model.get('annotator')
        creationTs: model.get('creation_ts')
        valueSource: model.get('value_source')
        status: model.get('status')
        autoRef: model.get('ref_to_auto')
        isConfirmed: model.get('is_confirmed')
      }