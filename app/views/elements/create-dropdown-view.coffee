View  = require 'views/base/view'

module.exports = class CreateDropdownView extends View
  autoRender: true
  className: 'create-dropdown-view'
  template: require './templates/create-dropdown'

  objectGroup: null

  initialize: (data) ->
    super data
    @objectGroup = data.objectGroup
    @labelKey = data.labelKey
    @route = data.route

  getTemplateData: ->
    objectGroup: @objectGroup
    labelKey: @labelKey
    route: @route