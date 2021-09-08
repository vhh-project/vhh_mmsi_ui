CaBaseCollection  = require './ca-base-collection'
ObjectDefinitions = require './object-definitions'
CaObject          = require './ca-object'

module.exports = class CaObjects extends CaBaseCollection
  detailModel       : CaObject
  objectType        : 'ca_objects'
  labelKey          : 'label.object'
  mediaType         : null

  bundles:
    'ca_object_representations.media.preview170':
      returnURL: true
    'ca_objects.type_id':
      returnAsArray: false
    'ca_objects.preferred_labels':
      returnAsArray: true
    'ca_objects.vhh_Title.TitleText':
      returnAsArray: true
    'ca_objects.vhh_Date':
      returnAsArray: true

  queryHook: (query) ->
    if @mediaType?
      switch(@mediaType)
        when 'any'
          # TODO: How to address any media type
          query.push('ca_object_representations.mimetype:*')

        when 'video'
          query.push('ca_object_representations.mimetype:video*')

        when 'image'
          query.push('ca_object_representations.mimetype:image*')

  parse: (data) ->
    if data?.results?
      for item in data.results
        item.subType = ObjectDefinitions.getSubTypeById(item['ca_objects.type_id'])

    super(data)