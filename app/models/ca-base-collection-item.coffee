Model = require 'models/base/model'

module.exports = class CaBaseCollectionItem extends Model
  getPreview170: ->
    previewUrl = @attributes['ca_object_representations.media.preview170']
    return null unless previewUrl?.indexOf('/media') > 0

    previewUrl = previewUrl.substr(previewUrl.indexOf('/media'))
    "#{window.settings.videoUrlBase}#{previewUrl}"

  getAttrValue: (attrKey, displaySubAttrIndex, searchSubAttrIndex, searchValues, joinString = '<br />') ->
    searchValues = [searchValues] unless _.isArray(searchValues)

    attr = @get(attrKey, false)
    return '' unless attr?.length > 0

    attr = _.map attr, (item) ->
      item.split(';')

    if searchSubAttrIndex?
      attr = _.filter attr, (item) ->
        item[searchSubAttrIndex] in searchValues and item[displaySubAttrIndex]?.length > 0

      return '' unless attr?.length > 0

    values = _.map attr, (item) ->
      item[displaySubAttrIndex]

    values.join(joinString)
