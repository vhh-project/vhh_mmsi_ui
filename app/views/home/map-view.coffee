Chaplin           = require 'chaplin'
utils             = require 'lib/utils'
CaPlacesMap       = require 'models/ca-places-map'
CaPlace           = require 'models/ca-place'
View              = require 'views/base/view'
BreadcrumbsView   = require 'views/elements/breadcrumbs-view'

module.exports = class MapView extends View
  autoRender: true
  template: require './templates/map'
  tooltipTemplate: require './templates/map-tooltip'
  infoTemplate: require './templates/map-info-item'
  detailsTemplate: require './templates/map-info-details'
  className: 'map-view'

  @imageOverlays = []

  # Fallback if no geocode can be determined at all as a starting point
  DEFAULT_GEOCODE: [48.210033, 16.363449]

  mapFilterKey: 'has_related'

  listen:
    'sync collection': 'redraw'

  events:
    'mouseover .map-info-item': 'mouseoverInfoItem'
    'mouseout .map-info-item': 'mouseoutInfoItem'
    'click .map-info-item > .map-info-header': 'clickItemHeader'
    'change #map-item-type-select': 'changeTypeSelect'

  initialize: ->
    super()

    @collection = new CaPlacesMap
    @loadedPlaces = []

  getTemplateData: ->
    mapFilterKey: @mapFilterKey

  attach: ->
    super()

    @breadcrumbsView = new BreadcrumbsView
      container: @$el.find('.breadcrumbs-container')
      title: lang._('label.map')
      icon: 'map'
      path: [
        { name: lang._('label.map') }
      ]

    @subview 'breadcrumbs', @breadcrumbsView

    @$mapWrapper = @$el.find('.map-view-wrapper')
    @$infoItems = @$el.find('.map-info-items')

    @addMaps @$mapWrapper,
      centerButton: true
      imageOverlays: true
      imageOverlayButton: true
      settingsKey: 'mapViewSettings'

  mapFinished: (map) ->
    super
    @leafletView = map
    @fetch()

  onMapMoveEnd: (event, map) ->
    super(event, map)
    @fetch()

  fetch: =>
    @collectionXhr?.abort()
    @collection?.geoBounds = @leafletView.getBounds()
    @collectionXhr = @collection.fetch()

  redraw: ->
    delete @collectionXhr
    @leafletView.featureGroup.clearLayers()
    @clearMapMarkers()
    @$infoItems.empty()
    sortedList = @collection.sortBy (model) ->
      model.get('ca_places.preferred_labels', false).toLowerCase()

    itemCount = 0

    for model in sortedList
      georeferences = model.get('ca_places.georeference', false)
      label = model.get('ca_places.preferred_labels', false)
      objectIds = model.get('ca_objects.object_id', false)
      entityIds = model.get('ca_entities.entity_id', false)
      eventIds = model.get('ca_occurrences.occurrence_id', false)
      placeIds = model.get('ca_places.related.place_id', false)
      collectionIds = model.get('ca_collections.collection_id', false)

      data =
        id: model.id
        label: label
        numObjects: objectIds?.length or 0
        numAgents: entityIds?.length or 0
        numEvents: eventIds?.length or 0
        numPlaces: placeIds?.length or 0
        numCollections: collectionIds?.length or 0

      data.numTotal = data.numObjects + data.numAgents + data.numEvents + data.numPlaces + data.numCollections

      if (@mapFilterKey == 'all') or (@mapFilterKey == 'has_related' and data.numTotal > 0) or (@mapFilterKey == 'empty' and data.numTotal == 0)
        @renderMarkerForPlace(georeferences, data)
        @renderPlaceInfo(data)
        itemCount++

    if itemCount == 0
      @$infoItems.append("<div><em>#{lang._('label.no_item_found')}</em></div>")

    else if @shownPlace? and @$infoItems.find(".map-info-item[data-id=\"#{@shownPlace.id}\"]").length == 1
      @revealPlaceDetail(@shownPlace, false)

  clearMapMarkers: ->
    if @mapMarkers?.length > 0
      for marker in @mapMarkers
        marker.off('click')
        marker.off('mouseover')
        marker.off('mouseout')

    @mapMarkers = []

  renderMarkerForPlace: (georeferences, data) ->
    for georeference in georeferences
      geocodes = utils.parseGeocode(georeference)

      for geocode in geocodes
        switch geocode.type
          when 'point'
            marker = L.marker([geocode.lat, geocode.long])

          when 'polygon'
            marker = L.polygon(geocode.points)

          when 'circle'
            marker = L.circle([geocode.lat, geocode.long], geocode.radius)

          else
            marker = null

        if marker?
          marker.placeId = data.id
          marker.on('click', @onMarkerClick)
          marker.on('mouseover', @onMarkerMouseover)
          marker.on('mouseout', @onMarkerMouseout)
          @leafletView.featureGroup.addLayer(marker)

          marker.bindTooltip(@tooltipTemplate(data))
          @mapMarkers.push(marker)

  renderPlaceInfo: (data) ->
    @$infoItems.append(@infoTemplate(data))

  onMarkerClick: (event) =>
    @showPlaceDetails(event.sourceTarget.placeId)

  onMarkerMouseover: (event) =>
    @$infoItems.find(".map-info-item[data-id=\"#{event.sourceTarget.placeId}\"]").addClass('hover')
    @highlightMarkersByPlaceId(event.sourceTarget.placeId)

  onMarkerMouseout: (event) =>
    @$infoItems.find('.map-info-item.hover').removeClass('hover')
    @mouseoutInfoItem()

  remove: ->
    @clearMapMarkers()

    super()

  mouseoverInfoItem: (event) ->
    @highlightMarkersByPlaceId(event.currentTarget.dataset.id)

  highlightMarkersByPlaceId: (placeId) ->
    @mouseoutInfoItem()
    
    @highlightedMarkers = _.filter @mapMarkers, (marker) ->
      marker.placeId == placeId

    for marker in @highlightedMarkers
      marker._icon?.src = '/mmsi/css/images/marker-icon-orange.png'

  mouseoutInfoItem: ->
    return unless @highlightedMarkers?

    for marker in @highlightedMarkers
      marker._icon?.src = '/mmsi/css/images/marker-icon.png'

    delete @highlightedMarkers

  clickItemHeader: (event) ->
    $topNode = $(event.currentTarget).parent()
    $collapse = $topNode.find('.collapse')
    
    if $collapse.hasClass('show')
      $collapse.collapse('hide')
      delete @shownPlace

    else
      @showPlaceDetails($topNode.data('id'))

  showPlaceDetails: (placeId) ->
    model = _.find @loadedPlaces, (model) ->
      model.id == placeId

    if model?
      @revealPlaceDetail(model)

    else
      model = new CaPlace id: placeId
      @loadedPlaces.push(model)
      model.fetch
        success: (model) =>
          @revealPlaceDetail(model)

  revealPlaceDetail: (model, showAnimation = true) ->
    @shownPlace = model
    @$infoItems.find('.collapse.show').collapse('hide')
    $item = @$infoItems.find(".map-info-item[data-id=\"#{model.id}\"]")
    $collapse = $item.find('.collapse')

    data =
      placeId: model.id
      empty: _.isEmpty(model.attributes.related)
      related: model.attributes.related      

    html = @detailsTemplate(data)
    
    $collapse.html(html)

    if showAnimation
      $collapse.collapse('show')
      $collapse.on 'shown.bs.collapse', (event) =>
        $collapse = $(event.currentTarget)
        $collapse.off('shown.bs.collapse')
        @scrollToCollapse($collapse)
        
    else
      $collapse.addClass('show')
      @scrollToCollapse($collapse, false)

  scrollToCollapse: ($collapse, showAnimation = true) ->
    $topNode = $collapse.closest('.map-info-item')
    top = $topNode.position().top + @$infoItems.scrollTop() - 4

    @$infoItems.stop()

    if showAnimation
      @$infoItems.animate
        scrollTop: top

    else
      @$infoItems.scrollTop(top)    

  changeTypeSelect: (event) ->
    @mapFilterKey = $(event.currentTarget).val()
    @redraw()



