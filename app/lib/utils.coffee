Chaplin = require 'chaplin'
# Application-specific utilities
# ------------------------------

# Delegate to Chaplin’s utils module.
utils = Chaplin.utils.beget Chaplin.utils

_.extend utils,
  # Padding for strings
  padStart: (value, length, character) ->
    value = "#{value}"

    return value if value.length >= length

    while value.length < length
      value = "#{character}#{value}"

    value

  parseGeocode: (geocodeValue) ->
    getLatLong = (value) ->
      return null unless value?.indexOf(',') > 1
      splitted = value.split(',')
      lat = parseFloat(splitted[0])
      long = parseFloat(splitted[1])

      return null if isNaN(lat) or isNaN(long)

      lat: lat, long: long

    return null unless geocodeValue?.length > 3 and geocodeValue[0] == '[' and geocodeValue[geocodeValue.length - 1] == ']'

    geocodes = geocodeValue.substr(1, geocodeValue.length - 2).split(':')

    result = []

    for geocode, index in geocodes
      if geocode.indexOf('~') > 0
        splitted = geocode.split('~')
        if splitted.length == 2
          latLong = getLatLong(splitted[0])
          radius = parseFloat(splitted[1])
          if latLong? and not isNaN(radius)
            result.push
              type: 'circle'
              lat: latLong.lat
              long: latLong.long
              radius: radius

      else if geocode.indexOf(';') > 0
        splitted = geocode.split(';')
        latLong = getLatLong(splitted[0])
        points = []
        
        for item in splitted
          point = getLatLong(item)
          if point?
            points.push([point.lat, point.long])
        
        if latLong? and points.length > 0
          result.push
            type: 'polygon'
            lat: latLong.lat
            long: latLong.long
            points: points

      else
        latLong = getLatLong(geocode)
        if latLong?
          result.push
            type: 'point'
            lat: latLong.lat
            long: latLong.long

    return null if result.length == 0
    result

  formatAttr: (labelValue, dataValue, type, item, attrs) ->
    result = ''

    switch type
      when 'vocabulary'
        if dataValue?
         model = window.bootstrap.caLists.get(dataValue)
         result = if model? then model.get('display_label') else null

        else
          result = "<span class=\"text-muted\"><em>(#{lang._('label.unknown')})</em></span>"

      when 'textarea'
        if labelValue?
          result = _.escape(labelValue).replace(/\n/g, '<br />')

      when 'url'
        if labelValue?.length > 0
          result = "<a href=\"#{_.escape(labelValue)}\" target=\"_blank\">#{_.escape(labelValue)}</a>"

      when 'urlWithTest'
        if attrs[item.testAttr]? and item.linkPatterns?
          pattern = _.find item.linkPatterns, (patternItem) ->
            patternItem.key == attrs[item.testAttr]?.label?.toLowerCase()
            
          if pattern?
            url = pattern.pattern.replace('%s', labelValue)
            result = "<a href=\"#{_.escape(url)}\" target=\"_blank\">#{_.escape(labelValue)}</a>"
          
          else
            result = labelValue

      when 'relation'
        if labelValue?.length > 0 and dataValue?
          if item.objectType == 'ca_places'
            result = "<a href=\"#{utils.reverse('details#place', id: dataValue)}\">#{labelValue}</a>"
          
          else if item.objectType == 'ca_entities'
            result = "<a href=\"#{utils.reverse('details#agent', id: dataValue)}\">#{labelValue}</a>"

      when 'geocode'
        result = "<div class=\"map-geocode map-geocode-details\" data-geocode=\"#{dataValue}\"></div>"

      else
        result = _.escape(labelValue) or ''

    result

  addLookupToInput: ($nodes, objectType) ->
    $nodes.each (index, node) =>
      $input = $(node)
      valueKey = $input.data('key')
      minLength = $input.data('lookup-min-length')

      unless typeof minLength == 'number'
        minLength = if minLength?.length > 0 then parseInt(minLength) else 3

      $input.autoComplete
        minLength: minLength
        resolverSettings:
          url: "#{window.settings.apiUrl}ca/service/item/ca_objects?lookup=1&bundle=#{objectType}.#{valueKey}"
          queryKey: 'term'
          fail: ->
              $input.parent().find('.input-spinner').remove()
        events:
          searchPre: (value, $input) ->
            if $input.parent().find('.input-spinner').length == 0
              $input.parent().append('<span class="input-spinner spinner-grow text-secondary spinner-grow-sm" role="status" aria-hidden="true"></span>')
            
            value

          searchPost: (results, $input) ->
            $input.parent().find('.input-spinner').remove()
            
            if results?.response? > 0
              results.response
            else
              []

  saveSettings: (key, value, inSession = false) ->
    storage = if inSession then window.sessionStorage else window.localStorage
    return unless storage?
    
    if _.isObject(value)
      value = JSON.stringify(value)

    else
      value = "#{value}"
    
    storage.setItem(key, value)

  loadSettings: (key, defaultValue, type='string', inSession = false) ->
    storage = if inSession then window.sessionStorage else window.localStorage
    return defaultValue unless storage?

    value = storage.getItem(key)
    value = defaultValue unless value?
    
    switch type
      when 'string'
        value

      when 'bool'
        value == 'true'

      when 'int'
        parseInt value

      when 'json'
        JSON.parse(value)

  isChildWindow: ->
    window.name == "vhhSecondWindow"

  renderLink: (url, text, addChildWindowLink = true) ->
    text = "<a href=\"#{url}\">#{text}</a>"

    if addChildWindowLink == true and not @isChildWindow()
      text += ' ' + @renderChildLink(url)

    text

  renderChildLink: (url) ->
    "<button type=\"button\" class=\"button-open-in-child-window\" data-url=\"#{url}\" title=\"#{lang._('tip.open_in_child_window')}\"><i class=\"fa fa-columns\"></i></button>"

  openRoute: (route, data, openInNewTab) ->
    if openInNewTab
      window.open("#{window.location.origin}#{Chaplin.utils.reverse(route, data)}", '_blank')

    else
      Chaplin.utils.redirectTo(route, data)

  escape: (value) ->
    if typeof value == 'string'
      _.escape(value)

    else if _.isArray(value)
      _.map value, (item) ->
        _.escape(item)

  setPageTitle: (title, useAppName = true) ->
    text = if useAppName then lang._('title.app_name') else ''

    if title?
      text += ' - ' if text.length > 0
      text += "#{title}" if title?

    document.title = text

# Prevent creating new properties and stuff.
Object.seal? utils

module.exports = utils
