CustomApplication = require 'models/custom-application'
Lang              = require 'models/lang'
CaLists           = require 'models/ca-lists'
UserMe            = require 'models/user-me'
routes            = require 'routes'

# Initialize the application on DOM ready event.
$ ->
  window.lang = new Lang 'en', window.settings.baseUrl

  $.ajaxSetup
    cache: false

  if window.settings.cookie?
    splittedCookies = window.settings.cookie.split('; ')

    for cookie in splittedCookies
      document.cookie = cookie

  window.bootstrap =
    caLists: new CaLists
    userMe: new UserMe
  
  lang.load (response) ->
    if response.status == 'success'
      window.bootstrap.userMe.fetch
        success: =>
          window.bootstrap.caLists.fetch
            success: =>
              window.app = new CustomApplication {
                title: 'VHH MMSI',
                controllerSuffix: '-controller',
                root: window.settings.baseUrl or '/',
                pushState: true
                routes
            }

    else
      console.warn('Could not load language file')
