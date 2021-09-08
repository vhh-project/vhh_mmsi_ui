module.exports = class Lang
  # The language code
  code: 'en'

  # List of localization strings (key, value)
  strings: null

  # List of special characters and other stuff
  internal: null

  # Date properties
  date: null

  # Relative URL of the language files
  url: 'lang/'

  # The standard comma sign
  comma: '.'

  # The standard thousand separator
  separator: ','

  # Set the standard language to 'en'
  constructor: (code = 'en', appUrl) ->
    @url = "#{appUrl}#{@url}" if appUrl?
    @code = code

  # Loads a language file
  load: (callback) ->
    $.ajax(
      type: 'GET'
      dataType: 'json'
      url: "#{@url}#{@code}.json"
    ).done(
      (response) =>
        @strings = response.strings or {}
        @internal = response.internal or {}
        @date = response.date or {}

        @comma = @internal.comma or '.'
        @separator = @internal.separator or ','

        #@parseDate(@date)
        
        callback
          status: 'success'
    ).error(
      (response) =>
        if response.status == 200
          console.warn 'JSON structure of language file seems to be corrupt'
          
        callback
          status: 'error'
    )

  parseDate: (data) ->
    return unless data?

    $.fn.datepicker.dates[@code] = 
      days: data.days.split('|')
      daysShort: data.days_short.split('|')
      daysMin: data.days_min.split('|')
      months: data.months.split('|')
      monthsShort: data.months_short.split('|')
      today: data.today
      monthsTitle: data.months_title
      clear: data.clear
      weekStart: Number(data.week_start)
      format: data.format
      titleFormat: data.title_format

  # Returns a localized string according to a key, if value set then a pruralized version is shown
  _: (key, value) ->
    return '' unless key?
    return @showKey(key) if window.showLanguageCodes == true

    string = @strings[key]
    return @showKey(key) unless string?
    return string unless value?

    strings = string.split '|'
    return string unless strings.length == 2

    strings[if value == 1 then 0 else 1]

  _s: (key, variables ...) ->
    return @showKey(key) if window.showLanguageCodes == true
    string = @_ key

    for variable, index in variables
      string = string.replace "$#{index + 1}", variable

    string

  _a: (key, separator = '|') ->
    return @showKey(key) if window.showLanguageCodes == true

    string = @strings[key]
    return @showKey(key) unless string?

    string.split separator

  has: (key) -> return @strings[key]?

  showKey: (key) ->
    "[#{key}]"

  find: (object) ->
    result = ''

    if typeof object == 'object'
      if object[@code]?
        result = object[@code]

      else
        console.warn "No language translation found in object: ", object

    result

  createDateString: (date, addTime = false) ->
    unless date?
      date = new Date

    year = date.getFullYear()
    month = date.getMonth() + 1
    day = date.getDate()

    month = "0#{month}" if month < 10
    day = "0#{day}" if day < 10

    result = "#{year}-#{month}-#{day}"

    if addTime
      hours = date.getHours()
      hours = "0#{hours}" if hours < 10
      minutes = date.getMinutes()
      minutes = "0#{minutes}" if minutes < 10
      seconds = date.getSeconds()
      seconds = "0#{seconds}" if seconds < 10

      result += "T#{hours}:#{minutes}:#{seconds}"

    result

  formatDate: (value) ->
    return '' unless typeof value == 'string' and value.length >= 10

    year = value.substr 0, 4
    month = value.substr 5, 2
    day = value.substr 8, 2
    
    @date.format.replace('mm', month).replace('dd', day).replace('yyyy', year)

  createDateFromUTCString: (value) ->
    year = Number value.substr(0, 4)
    month = Number(value.substr(5, 2)) - 1
    day = Number value.substr(8, 2)

    if value .length >= 19
      hours = Number value.substr(11, 2)
      minutes = Number value.substr(14, 2)
      seconds = Number value.substr(17, 2)

      if value.length >= 24
        # Must be "real" UTC
        new Date Date.UTC(year, month, day, hours, minutes, seconds)

      else 
        # Must be some Date without localiztion
        new Date year, month, day, hours, minutes, seconds

    else
      # Just a Date, no time
      new Date year, month, day, 0, 0, 0

  formatDateTime: (value) ->
    fillDigit = (value) ->
      value = "#{value}"
      value = "0#{value}" if value.length == 1
      value

    return '' unless typeof value == 'string' and value.length >= 19



    date = @createDateFromUTCString value
    
    year = date.getFullYear()
    month = fillDigit (date.getMonth() + 1)
    day = fillDigit date.getDate()

    hours = fillDigit date.getHours()
    minutes = fillDigit date.getMinutes()
    seconds = fillDigit date.getSeconds()
    
    @date.format_datetime.replace('mm', month).replace('dd', day).replace('yyyy', year).replace('HH', hours).replace('MM', minutes)

  formatBoolean: (value) ->
    if value then @internal.yes else @internal.no

  formatYearMonth: (value) ->
    return '' unless value.length >= 7

    year = value.substr 0, 4
    month = value.substr 5, 2

    @date.format_yearmonth.replace('mm', month).replace('yyyy', year)

  formatLanguage: (value) ->
    @internal["lang.#{value}"] or ''

  formatInteger: (value, decimals, showThousandSeparator = true) ->
    return '' unless value?

    isNegative = true if value < 0

    value = value.toString()

    if isNegative
      value = value.substr 1

    if decimals? and decimals > 0
      if value.length <= decimals
        result = '0'
        afterComma = value

        if afterComma.length < decimals
          for index in [0 .. decimals - afterComma.length - 1]
            afterComma = "0#{afterComma}"

      else
        result = value.substr 0, value.length - decimals
        afterComma = value.substr -decimals

    else
      result = value


    result = result.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1#{@internal.separator}") if showThousandSeparator
    result += "#{@internal.comma}#{afterComma}" if afterComma
    result = "-#{result}" if isNegative
    result

  stringToInteger: (value, decimals) ->
    return null unless value?.length > 0

    if decimals? and decimals > 0
      splittedString = value.split @internal.comma

      return NaN unless splittedString.length < 3
      
      beforeComma = splittedString[0]
      afterComma = if splittedString.length == 2 then splittedString[1] else '0'

      beforeComma = beforeComma.replace /\./g, ''
      afterComma = afterComma.replace /\./g, ''

      if afterComma.length < decimals
        for index in [ afterComma.length .. decimals - 1 ]
          afterComma += '0'

      else if afterComma.length > decimals
        afterComma = afterComma.substr 0, decimals

      Number "#{beforeComma}#{afterComma}"

    else
      Number value

  formatTime: (value) ->
    value.substr 0, 5

  formatNumber: (value, decimalCount = 2) ->
    integer = Math.floor value
    result = @formatInteger integer
    return result unless decimalCount > 0

    result += @internal.comma

    value = value - integer

    for i in [1 .. decimalCount]
      value = value * 10
      result += Math.floor(value).toString()

    result

  getLanguageOptions: ->
    [
      { value: 'de', name: @internal['lang.de'] }
      { value: 'en', name: @internal['lang.en'] }
    ]