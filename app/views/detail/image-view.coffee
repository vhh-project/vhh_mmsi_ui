View          = require 'views/base/view'

module.exports = class DetailImageView extends View
  autoRender: true
  className: 'detail-image-view'
  template: require './templates/image'

  getTemplateData: ->
    imageUrl: @model.getPrimaryImageUrl()
