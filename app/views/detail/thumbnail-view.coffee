View      = require 'views/base/view'
ModalView = require 'views/elements/modal-view'

module.exports = class DetailThumbnailView extends View
  autoRender: true
  className: 'detail-thumbnail-view'
  template: require './templates/thumbnail'

  events:
    'change .input-upload-thumbnail': 'changeThumbnail'
    'click .button-thumbnail-delete': 'clickDelete'

  initialize: (data) ->
    super(data)

    @canEdit = data.canEdit

  getTemplateData: ->
    {
      imageUrl: @model.getPrimaryImageUrl()
      thumbUrl: @model.getPrimaryThumbUrl()
      canEdit: @canEdit
    }

  changeThumbnail: (event) ->
    return unless event.currentTarget.files?.length == 1
    file = event.currentTarget.files[0]
    $form = $(event.currentTarget.parentNode)
    $form.find('.is-invalid').removeClass('is-invalid')
    $form.find('.invalid-feedback').remove()

    if file.type in ['image/png', 'image/jpeg']
      @addSpinner(@$el.find('.card-body'))
      @model.uploadThumb(file, @onUploaded)

    else
      $form.find('.form-control').addClass('is-invalid')
      $form.append("<div class=\"invalid-feedback\">#{lang._('error.thumbnail_mime_type')}</div>")

  onUploaded: (response) =>
    @removeSpinner()
    @render() if response.success

  clickDelete: (response) =>
    new ModalView
      header: lang._('header.delete_thumbnail')
      content: lang._('message.confirm_delete_thumbnail')
      confirmText: lang._('button.delete')
      parent: @
      callback: =>
        @addSpinner(@$el.find('.card-body'))
        @model.deleteThumb(@onUploaded)

        true








