  exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(vendor|node_modules|local_node_modules)/

    stylesheets:
      joinTo: 'css/app.css'

    templates:
      joinTo: 'js/app.js'

  npm:
    aliases:
      backbone: 'exoskeleton'

    globals:
      _: 'lodash'
      $: 'jquery'
      Popper: 'popper.js'
      bootstrap: 'bootstrap'
      bootstrapAutocomplete: 'bootstrap-autocomplete'
      L: 'leaflet'
      LeafletDraw: 'leaflet-draw'
      LeafletEasyButton: 'leaflet-easybutton'
      LeafletToolbar: 'leaflet-toolbar'
      Geocoder: 'leaflet-control-geocoder'

    styles:
      '@fortawesome/fontawesome-free': [ 'css/all.css' ]
      'vhh-video-player': [ 'dist/css/vhh-video-player.css', 'dist/css/vhh-filmstrip.css' ]
      'leaflet': [ 'dist/leaflet.css' ]
      'leaflet-draw': [ 'dist/leaflet.draw.css' ]
      'leaflet-control-geocoder': [ 'dist/Control.Geocoder.css' ]
      'leaflet-easybutton': [ 'src/easy-button.css' ]
      'leaflet-distortableimage': [ 'dist/vendor.css', 'dist/leaflet.distortableimage.css' ]

    static: [
      'local_node_modules/vhh-video-player/dist/js/vhh-video-player.js'
      'local_node_modules/vhh-video-player/dist/js/vhh-filmstrip.js'
      'local_node_modules/vhh-video-player/dist/js/vhh-video-mediator.js'
      'node_modules/leaflet-google/dist/leaflet-google.js'
      'node_modules/leaflet.fullscreen/Control.FullScreen.js'
      'node_modules/leaflet-distortableimage/dist/leaflet.distortableimage.js'
    ]

  plugins:
    autoReload:
      enabled:
        css: true
        js: true
        assets: false
      delay: 200
    copyfilemon:
      webfonts: ['node_modules/@fortawesome/fontawesome-free/webfonts/' ]
      images: ['node_modules/leaflet.fullscreen/icon-fullscreen.png', 'node_modules/leaflet.fullscreen/icon-fullscreen-2x.png']
    replacer:
      # Replace the popper.js string since require does not work with the dot
      dict: [
        {
          path: 'public/js/vendor.js'
          items: [
            { key: "['\"]popper\\.js['\"]", value: "'popper_js'" }
            { key: "jQuery,window", value: "$,window" }
          ]
        }
      ]