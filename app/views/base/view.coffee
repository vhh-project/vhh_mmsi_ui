Chaplin = require 'chaplin'
utils     = require 'lib/utils'
require 'lib/view-helper' # Just load the view helpers, no return value

module.exports = class View extends Chaplin.View
  # Auto-save `template` option passed to any view as `@template`.
  optionNames: Chaplin.View::optionNames.concat ['template']
  settings: null
  hotkeys: null
  bodyClass: null

  MAP_DEFAULT_GEOCODE: [48.210033, 16.363449]
  MAP_DEFAULT_ZOOM: 13

  @mapOverlayOpacity: 0.5

  initialize: ->
    @loadSettings()
    super()

    $('body').addClass(@bodyClass) if @bodyClass?
    @leafletViews = []

    if _.isObject(@hotkeys)
      $(document).on 'keydown', @handleHotkeys

  loadSettings: ->
    return unless @settings? and @__proto__?.constructor?.name?
    
    for key, value of @settings
      @settings[key] = utils.loadSettings("#{@__proto__.constructor.name}.#{key}", value)

  saveSetting: (key, value) ->
    return unless @settings? and @__proto__?.constructor?.name?

    @settings[key] = value
    utils.saveSettings("#{@__proto__.constructor.name}.#{key}", value)

  # Precompiled templates function initializer.
  getTemplateFunction: ->
    @template

  handleHotkeys: (event) =>
    return if event.target.nodeName in ['INPUT'] or event.metaKey == true or event.ctrlKey == true or event.altKey == true
    
    hotkey = _.find @hotkeys, (hotkey) ->
      shiftKey = hotkey.shiftKey == true

      return if shiftKey != event.shiftKey

      if typeof hotkey.key == 'string'
        found = hotkey.key == event.key

      else if typeof hotkey.key == 'number'
        found = hotkey.key == event.keyCode

    return unless hotkey?

    event.stopPropagation()
    event.preventDefault()

    @[hotkey.func]?()

  isMobile: ->
    document.body.clientWidth <= 767

  activateTooltips: ->
    return if @isMobile()

    $toAssign = $('.has-tip')

    return if $toAssign.length == 0

    $toAssign.tooltip()    
    $toAssign.removeClass('has-tip')
    $toAssign.addClass('tip-assigned')

  removeTooltips: ($el) ->
    $el = @$el unless $el?
    $el.find('.tip-assigned').tooltip('dispose')

  remove: ->
    @removeTooltips()
    @removeSpinner()
    @removeMaps()
    $('body').removeClass(@bodyClass) if @bodyClass?

    super()

  addSpinner: ($node) ->
    if $node?
      $node.append "<div class=\"spinner-container\"><div class=\"spinner-border text-primary\" role=\"status\"><span class=\"sr-only\">#{lang._('label.spinner_loading')}</span></div></div>"

    else
      $('body').append "<div class=\"spinner-container spinner-container-fixed\"><div class=\"spinner-border text-primary\" role=\"status\"><span class=\"sr-only\">#{lang._('label.spinner_loading')}</span></div></div>"

  removeSpinner: ($node) ->
    if $node?
      $node.find('.spinner-container').remove()

    else
      $('.spinner-container').remove()

  scrollTo: ($node, offset) ->
    offset = 24 unless offset?

    bodyOffset = $('body').css('padding-top').replace(/[^0-9.]/g, '')
    bodyOffset = if bodyOffset.length > 0 then parseInt(bodyOffset) else 0

    $('html, body').animate
      scrollTop: $node.offset().top - offset - bodyOffset

  addMaps: ($targetNodes, options = {}) ->
    return unless $targetNodes?.length > 0

    addedMaps = []

    unless L.Control.FullScreen
      require('leaflet.fullscreen')

    $targetNodes.each (nodeIndex, node) =>
      addedMaps.push(@addMap(node, options))

    if options.centerButton == true
      @mapAddCenterButtons(addedMaps)

    if options.imageOverlays == true
      @mapAddImageOverlayButtons(addedMaps) if options.imageOverlayButton == true

      if View.mapImageOverlays?.length > 0
        for map in addedMaps
          map.imageOverlays = []

          for item in View.mapImageOverlays
            map.imageOverlays.push
              image: item.image
              layer: @mapAddImageOverlay(map, item.image, item.corners, options.imageOverlayButton == false)
              corners: item.corners

    addedMaps

  addMap: (node, options) ->
    map = L.map(node)
    node.setAttribute('leaflet-id', map._leaflet_id)
    @leafletViews.push(map)

    map.mapOptions = options

    featureGroup = new L.FeatureGroup()

    @setTileLayer(map, 'ROADMAP')

    @addMapViewButton(map, 'fa-road', 'ROADMAP', 'tip.map_roadmap_view', true)
    @addMapViewButton(map, 'fa-satellite', 'SATELLITE', 'tip.map_satellite_view')
    @addMapViewButton(map, 'fa-mountain', 'TERRAIN', 'tip.map_terrain_view')

    map.addControl(new L.Control.FullScreen())

    map.addLayer(featureGroup)
    map.featureGroup = featureGroup

    @mapAddDrawControl(map, options.$targetInput) if options.$targetInput?
    @mapAddGeocoder(map)

    geocodes = utils.parseGeocode(node.dataset.geocode)

    if geocodes?.length > 0
      @mapAddGeocodes(map, geocodes)

    else
      @mapSetInitialCenter(map)

    map

  mapAddGeocodes: (map, geocodes) ->
    return unless geocodes?.length > 0

    map.setView([geocodes[0].lat, geocodes[0].long], @MAP_DEFAULT_ZOOM)

    for geocode in geocodes
      switch geocode.type
        when 'point'
          map.featureGroup.addLayer(L.marker([geocode.lat, geocode.long]))

        when 'polygon'
          map.featureGroup.addLayer(L.polygon(geocode.points))

        when 'circle'
          map.featureGroup.addLayer(L.circle([geocode.lat, geocode.long], geocode.radius))

  removeMaps: (maps, saveOverlays = true) ->
    return unless @leafletViews?

    maps = @leafletViews.slice() unless maps?

    for map in maps
      @removeMap(map, saveOverlays)

  getMapById: (mapId) ->
    return null unless mapId?
    mapId = parseInt(mapId)

    return null if isNaN(mapId)

    for map in @leafletViews
      if map._leaflet_id == mapId
        return map

  removeMapById: (mapId, saveOverlays = true) ->
    map = @getMapById(mapId)
    @removeMap(map, saveOverlays) if map?

  removeMap: (map, saveOverlays = true) ->
    index = _.indexOf @leafletViews, map

    return if index == -1

    @leafletViews.splice(index, 1)

    if saveOverlays and map.mapOptions.imageOverlayButton == true and map.imageOverlays?
      View.mapImageOverlays = _.filter map.imageOverlays, (item) =>
        item.layer? and map._layers[item.layer._leaflet_id]?

      for item in View.mapImageOverlays
        item.corners = item.layer.getCorners()
        item.layer = null

      Chaplin.mediator.publish('map:overlays-updated', View.mapImageOverlays)

    map.featureGroup.clearLayers()
    map.off('moveend')

  mapSetInitialCenter: (map) ->
    if map.mapOptions.settingsKey?
      mapSettings = utils.loadSettings(map.mapOptions.settingsKey, null, 'json')

    if mapSettings?.center?
      geocode = [mapSettings.center.lat, mapSettings.center.lng]
      map.setView(geocode, mapSettings.zoom or @MAP_DEFAULT_ZOOM)
      @mapFinished(map)

    else
      if window.settings.localDev != true and navigator.geolocation?
        navigator.geolocation.getCurrentPosition(
          (position) =>
            map.setView([position.coords.latitude, position.coords.longitude], @MAP_DEFAULT_ZOOM)
            @mapFinished(map)
          , (errorCode) =>
            map.setView(@MAP_DEFAULT_GEOCODE, @MAP_DEFAULT_ZOOM)
            @mapFinished(map)
        ) 
      else
        map.setView(@MAP_DEFAULT_GEOCODE, @MAP_DEFAULT_ZOOM)
        @mapFinished(map)

    map.on('moveend', @onMapMoveEnd)

  mapAddCenterButtons: (maps) ->
    return if window.settings.localDev == true or not navigator.geolocation?
    
    navigator.geolocation.getCurrentPosition (position) =>
      for map in maps
        centerButton = L.easyButton('fa fa-crosshairs',
          (button, map) ->
            map.locate
              setView: true
              maxZoom: @MAP_DEFAULT_ZOOM
          , lang._('tip.map_goto_device_location')
        )

        centerButton.addTo(map)

  mapAddImageOverlayButtons: (maps) ->    
    for mapItem in maps
      if mapItem.mapOptions.imageOverlays == true and not mapItem.hasImageOverlayButton
        mapItem.hasImageOverlayButton = true
        addButton = L.easyButton('fa fa-image',
          (button, map) =>
            return if @mapButtonPressed == true
            @mapButtonPressed = true

            window.setTimeout(
              =>
                delete @mapButtonPressed
              , 500
            )

            $('#map-image-file-chooser').remove()
            $('body').append('<input type="file" id="map-image-file-chooser" />')
            $('#map-image-file-chooser').on('change', 
              (event) =>
                file = event.currentTarget.files[0]
                return unless file.type in ['image/png', 'image/jpeg']

                reader = new FileReader
                _view = @

                reader.onload = ->
                  map.imageOverlays = [] unless map.imageOverlays?
                  map.imageOverlays.push
                    image: @result
                    layer: _view.mapAddImageOverlay(map, @result)
                    corners: null

                reader.readAsDataURL(file)
            ).click()
          , lang._('tip.map_add_image_overlay')
        )

        addButton.addTo(mapItem)

        transparencyButton = L.easyButton('fa fa-tint',
          (button, map) =>
            return if @mapButtonPressed == true
            @mapButtonPressed = true

            window.setTimeout(
              =>
                delete @mapButtonPressed
              , 500
            )
            title = lang._('tip.map_toggle_overlay_opacity') + ' ' + Math.floor(@mapNewImageOverlayOpacity() * 100) + '%'
            button.button.setAttribute('title', title)
            View.mapOverlayOpacity = @mapNewImageOverlayOpacity()
            L.DistortableImage.Edit.prototype.options.opacity = View.mapOverlayOpacity
            $image = $(map._container).find('.leaflet-overlay-pane > img.leaflet-image-layer')
            if $image.css('opacity') != '1'
              $image.css('opacity', View.mapOverlayOpacity)
          lang._('tip.map_toggle_overlay_opacity') + ' ' + Math.floor(@mapNewImageOverlayOpacity() * 100) + '%'
        )

        transparencyButton.addTo(mapItem)

  mapNewImageOverlayOpacity: ->
    if View.mapOverlayOpacity == 0.5 then 0.75 else 0.5

  mapAddImageOverlay: (map, imageData, corners, locked = false) ->
    L.DistortableImage.Edit.prototype.options.opacity = View.mapOverlayOpacity
    
    if locked
      options =
        mode: 'lock'
        actions: [
          L.LockAction
          L.OpacityAction
        ]

    else
      options =
        mode: 'scale'
        actions: [
          L.DragAction
          L.ScaleAction
          L.DistortAction
          L.RotateAction
          L.FreeRotateAction
          L.LockAction
          L.OpacityAction
          L.BorderAction
          L.DeleteAction
        ]

    if corners?
      options.corners = corners

    L.distortableImageOverlay(imageData, options).addTo(map)

  mapFinished: (map) ->
    # Dummy for other use

  onMapMoveEnd: (event, map) =>
    data = 
      center: event.target.getCenter()
      zoom: event.target.getZoom()

    if event.target.mapOptions.settingsKey?
      utils.saveSettings(event.target.mapOptions.settingsKey, data)

  mapAddGeocoder: (map) ->
    geocoder = L.Control.geocoder
      defaultMarkGeocode: false
      geocoder: L.Control.Geocoder.google(apiKey: window.settings.geocoderApiKey)

    geocoder.on('markgeocode', @mapMarkGeocode)

    map.addControl(geocoder);

  mapMarkGeocode: (event) ->
    map = event.sourceTarget._map
    bbox = event.geocode.bbox
    map.setView(event.geocode.center, @MAP_DEFAULT_ZOOM)

  mapAddDrawControl: (map, $targetInput) ->
    # Add draw controls (leaflet-draw)
    drawControl = new L.Control.Draw
      position: 'topleft'
      edit:
        featureGroup: map.featureGroup
        edit: {}
        remove: {}
        poly: {}
        allowIntersection: true
      draw:
        polyline: false
        polygon: {}
        rectangle: {}
        circle: {}
        marker: {}
        circlemarker: false

    map.addControl(drawControl);

    $(map._container).data('target-input', $targetInput)

    map.on L.Draw.Event.CREATED, (event, map) =>
      return unless event.layerType in ['marker', 'circle', 'polygon', 'rectangle']
      event.sourceTarget.featureGroup.addLayer(event.layer)
      @mapUpdateLayers(event.sourceTarget)

    map.on L.Draw.Event.EDITED, (event) =>
      @mapUpdateLayers(event.sourceTarget)

    map.on L.Draw.Event.DELETED, (event) =>
      @mapUpdateLayers(event.sourceTarget)

  mapUpdateLayers: (map) ->
    result = []

    for layerKey, layer of map.featureGroup._layers
      # Polygon
      if layer._latlngs?
        for polygonItem in layer._latlngs
          polygon = _.map polygonItem, (latlng) ->
            "#{latlng.lat},#{latlng.lng}"

          result.push(polygon.join(';'))
      
      else if layer._latlng?
        # Circle
        if layer._mRadius?
          result.push("#{layer._latlng.lat},#{layer._latlng.lng}~#{layer._mRadius}")

        # marker
        else
          result.push("#{layer._latlng.lat},#{layer._latlng.lng}")

    result = if result.length == 0 then '' else "[#{result.join(':')}]"
    $(map._container).data('target-input').val(result)

  setTileLayer: (map, type) ->
    map.removeLayer(map.tileLayer) if map.tileLayer?
    map.tileLayer = L.gridLayer.googleLayer
      maptype: type
      googlekey: window.settings.mapApiKey

    map.addLayer(map.tileLayer)
    map.tileLayer.addTo(map)

  addMapViewButton: (map, iconClass, type, title, active = false) ->
    map.mapStateButtons = {} unless map.mapStateButtons?

    title = lang._(title)

    inactiveState =
      stateName: 'map-state-button-inactive'
      icon: iconClass
      title: title
      onClick: (button, map) =>
        selectedKey = 'ROADMAP'
        
        for key, stateButton of map.mapStateButtons
          if stateButton == button
            selectedKey = key
            stateButton.state('map-state-button-active') 
          
          else
            stateButton.state('map-state-button-inactive') 
        
        @setTileLayer(map, selectedKey)

    states = [
      {
        stateName: 'map-state-button-active'
        icon: iconClass
        title: title
      }
    ]

    if active
      states.push(inactiveState)

    else
      states.unshift(inactiveState)
    
    button = L.easyButton(
      id: 'map-view-button-' + map._leaflet_id + '-' + type
      position: 'bottomright'
      states: states
    )
    
    map.mapStateButtons[type] = button
    button.addTo(map)
