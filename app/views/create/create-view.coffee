require 'views/elements/partials'
utils             = require 'lib/utils'
Chaplin           = require 'chaplin'
mediator          = require 'mediator'
View              = require 'views/base/view'
BreadcrumbsView   = require 'views/elements/breadcrumbs-view'

module.exports = class CreateView extends View
  autoRender: false
  className: 'create-view'
  template: require './templates/create'
  errorTemplate: require 'views/detail/templates/errors'
  editTemplate: require 'views/detail/templates/edit'

  events:
    'submit #create-view-form': 'submit'
    'click .button-cancel': 'clickCancel'
    'keyup .form-control': 'changeFormControl'
    'change .form-control': 'changeFormControl'

  initialize: (data) ->
    super(data)

    @model = new data.model(intrinsic_fields: type_id: data.typeId)
    @detailRoute = data.detailRoute
    @parentBreadcrumb = data.parentBreadcrumb
    @model.loadCaDefinition => @render()

  getTemplateData: ->
    @attrGroups = @model.createAttrGroupsForCreation()
    
    attrGroups: @attrGroups

  attach: ->
    super()

    objectGroups = @model.getObjectType()

    @$form = @$el.find('form')
    @$form.find(':input:first').focus()

    @breadcrumbsView = new BreadcrumbsView
      container: '.breadcrumbs-container'
      title: "#{lang._('label.create')} #{lang._(objectGroups.label)}"
      icon: objectGroups.icon
      path: [
        { name: lang._(@parentBreadcrumb.label), href: utils.reverse(@parentBreadcrumb.route)}
        { name: lang._(objectGroups.label) }
      ]

    # Add autosuggest
    utils.addLookupToInput(@$form.find('.input-lookup'), @model.objectType)

    @subview 'breadcrumbs', @breadcrumbsView

  submit: (event) ->
    event.preventDefault()
    @$form.find('.create-errors').remove()
    @$form.find('.invalid-feedback').remove()

    result = {}
    error = false

    $detailRows = @$form.find('.detail-row')
    $detailRows.each (index, detailRow) =>
      definition = @attrGroups[detailRow.dataset['index']]
      data = @model.validate($(detailRow), definition)

      if data?
        for key, object of data
          if key == 'new'
            result.new = {} unless _.has(result, 'new')

            for subKey, subObject of object
              result.new[subKey] = subObject

          else
            result[key] = object

      else
        error = true

    return if error
    
    result.intrinsic_fields = @model.get('intrinsic_fields')

    @addSpinner(@$el)
    @model.saveAttributes result, @onDataSaved

  onDataSaved: (response) =>
    @removeSpinner(@$el)

    if response.success
      mediator.publish('application:editing', false)
      Chaplin.utils.redirectTo(@detailRoute, id: response.id)

    else if response.errors?.length > 0
      @showErrors(response.errors)

    else
      @showErrors([lang._('error.unkown_api_error')])

  showErrors: (errorList) ->
    html = @errorTemplate
      errors: errorList
    
    @$form.prepend("<div class=\"row create-errors\">#{html}</div>")

  clickCancel: ->
    mediator.publish('application:editing', false)
    Chaplin.utils.redirectTo(@parentBreadcrumb.route)
  
  changeFormControl: ->
    mediator.publish('application:editing', true)
