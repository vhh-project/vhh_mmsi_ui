# Application-specific view helpers
# http://handlebarsjs.com/#helpers
# --------------------------------
Chaplin = require 'chaplin'
utils   = require './utils'

register = (name, fn) ->
  Handlebars.registerHelper name, fn

# Map helpers
# -----------

# Make 'with' behave a little more mustachey.
register 'with', (context, options) ->
  if not context or Handlebars.Utils.isEmpty context
    options.inverse(this)
  else
    options.fn(context)

# Inverse for 'with'.
register 'without', (context, options) ->
  inverse = options.inverse
  options.inverse = options.fn
  options.fn = inverse
  Handlebars.helpers.with.call(this, context, options)

# Get Chaplin-declared named routes. {{url "likes#show" "105"}}
register 'url', (routeName, params..., options) ->
  utils.reverse routeName, params

register '_', (key, value, options) ->
  unless options?
    options = value
    value = null

  lang._ key, value

register '_s', (base, key, options) ->
  langKey = "#{base}#{key}"
  
  if lang.has(langKey)
    lang._(langKey)

  else
    key

register 'ifEqual', (value, test, options) ->
  if typeof value1 == 'object' and _.isEqual(value1, test)
    return options.fn this
  else if value == test
    return options.fn this
  else
    return options.inverse this

register 'unlessEqual', (value, test, options) ->
  if typeof value1 == 'object' and _.isEqual(value1, test)
    return options.inverse this
  else if value == test
    return options.inverse this
  else
    return options.fn this

register 'baseUrl', (options) ->
  window.settings.baseUrl

register 'listItemValue', (value, options) ->
  model = window.bootstrap.caLists.get(value)

  if model?
    model.get('display_label')

  else
    value

register 'byKey', (object, key, valueKey, options) ->
  return '' unless _.has(object, key)

  unless options?
    options = valueKey
    valueKey = null

  object = object[key]

  if valueKey?
    object[valueKey]

  else
    object

register 'vocabularySelect', (defItem, value, index, attrKey, options) ->
  list = window.bootstrap.caLists.getById(defItem.listId, true)
  index = if index? then index else ''

  return '<em>(list type not found)</em>' unless list?

  html = []

  html.push "<select class=\"form-control custom-select\" data-index=\"#{index}\" data-attr-key=\"#{attrKey}\" data-key=\"#{defItem.key}\">"
  html.push "<option value=\"\">#{lang._('label.select_value')}</option>"

  for item in list
    name = if item.depth > 1 then "#{Array(item.depth).join('&nbsp;&nbsp;&nbsp;')}#{item.name}" else item.name

    if item.id == "#{value}"
      html.push "<option selected value=\"#{item.id}\">#{name}</option>"

    else if item.enabled
      html.push "<option value=\"#{item.id}\">#{name}</option>"

    else
      html.push "<option value=\"#{item.id}\" disabled>#{name}</option>"

  html.push '</select>'
  html.join("\n")

register 'createLinksFromUrls', (value, options) ->
  return '' unless typeof value == 'string'
  value = _.escape(value)
  regExp = /(http|https):\/\/(.*?)($| |,|;)/gi
  value.replace(regExp, '<a href="$1://$2" target="_blank">$1://$2</a>$3');

register 'padding', (value, character, startIndex, options) ->
  unless options?
    options = startIndex
    startIndex = 0

  value = value - startIndex

  return '' unless value > 0
  _.repeat(character, value)

register '_log', (value, options) ->
  console.log(value)      # Log in view helper
  '(log)'

register 'childLink', (route, id, options) ->
  url = Chaplin.utils.reverse(route, id: id)
  new Handlebars.SafeString(utils.renderChildLink(url))

register 'tooltipIcon', (text, options) ->
  text = text.replace(/"/g, '&quot;')
  text = text.replace(/[\n\r]/g, '')
  new Handlebars.SafeString("<span class=\"has-tip d-print-none\" data-placement=\"top\" data-html=\"true\" title=\"#{text}\"><i class=\"fa fa-info-circle\"></i></span>")
