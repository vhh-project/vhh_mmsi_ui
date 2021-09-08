Collection            = require './base/collection'
CaBaseCollectionItem  = require './ca-base-collection-item'
CaBaseModel           = require './ca-base-model'
ObjectDefinitions     = require './object-definitions'

module.exports = class CaBaseCollection extends Collection
  PAGE_COUNT: 20
  model: CaBaseCollectionItem
  detailModel: CaBaseModel

  query: null

  # "created" or "modified"
  userEdited: null
  
  bundles:
    'ca_objects.type_id':
      returnAsArray: false

  objectType: 'ca_objects'
  
  page: 1
  totalCount: 0

  sortCriteria: null
  sortDirection: 'asc'

  url: ->
    query = []

    if @userEdited?
      if @editedPeriod?
        switch @editedPeriod
          when 'today'
            period = 'today'

          when 'yesterday'
            period = 'yesterday'

          when 'this_month'
            now = new Date()
            year = now.getFullYear()
            month = now.getMonth() + 1

            period = "#{month}/#{year}"

          when 'last_month'
            now = new Date()
            year = now.getFullYear()
            month = now.getMonth()

            if month == 0
              month = 12
              year--

            period = "#{month}/#{year}" 

      else
        period = 'after 2000'

      query.push "#{@userEdited}.#{window.bootstrap.userMe.get('username')}:\"#{period}\""

    if @typeId?
      query.push "#{@objectType}.type_id:#{@typeId}"

    @queryHook?(query)

    if @query?.length
      query.push @query

    else
      query.push '*' unless query.length

    query = query.join(' AND ')

    # Paging
    pageStart = (@page - 1) * @PAGE_COUNT
    pageLimit = @PAGE_COUNT

    url = "#{window.settings.apiUrl}ca/service/find/#{@objectType}/?q=#{query}&start=#{pageStart}&limit=#{pageLimit}"

    if @sortCriteria?
      url += "&sort=#{@sortCriteria}&sortDirection=#{if @sortDirection == 'asc' then 'asc' else 'desc'}"

    @addCachePrevention(url)

  loadCaDefinition: (callback) ->
    ObjectDefinitions.loadCaDefinition(@objectType, callback)

  fetch: (options = {}) ->
    data = {}
    data.bundles = @bundles if @bundles?

    options =
      type: 'POST'
      cache: false
      contentType: 'application/json'
      data: JSON.stringify(data)

    super(options)

  parse: (data) ->
    if data?.results?
      @totalCount = data.total or 0
      return data.results

    else
      @totalCount = 0
      []

  getAllTypeIdsFilterString: ->
    ObjectDefinitions.getAllTypeIdsFilterString(@objectType)




