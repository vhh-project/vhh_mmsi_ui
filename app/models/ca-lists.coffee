Collection = require 'models/base/collection'

module.exports = class CaLists extends Collection
  url: -> 
    "#{window.settings.apiUrl}ca/service/find/ca_list_items?q=*"

  fetch: (options = {}) ->
    data =
      bundles:
        "ca_list_items.list_id": 
          returnAsArray : false
        "ca_list_items.parent_id":
          returnAsArray: false
        "ca_list_items.is_enabled":
          returnAsArray: false
    

    options.type = 'POST'
    options.contentType = 'application/json'
    options.data = JSON.stringify(data)
    super(options)

  parse: (data) ->
    return [] unless data?.results?

    idList = {}

    for item in data.results
      idList[item.id] = item['ca_list_items.parent_id']

    for item in data.results
      searchId = item['ca_list_items.parent_id']
      depth = 1
      idHistory = []
      
      while _.has(idList, searchId) and searchId not in idHistory
        depth++
        idHistory.push(searchId)
        searchId = idList[searchId]

      item.depth = depth

    data.results

  getById: (listId, sort = false) ->
    listId = "#{listId}"
    result = _.map(@filter(
        (model) -> 
          model.get('ca_list_items.list_id', false) == listId and
          model.get('depth') == 1
      ), (model) ->
        id: model.id
        name: model.get('display_label')
        enabled: model.get('ca_list_items.is_enabled', false) == '1'
        depth: model.get('depth')
      )

    if sort == true
      result = _.sortBy result, (item) -> item.name?.toLowerCase()

    depth = 2
    done = false

    while depth < 10 and not done
      list = _.map(@filter(
          (model) -> 
            model.get('ca_list_items.list_id', false) == listId and
            model.get('depth') == depth
        ), (model) ->
          id: model.id
          name: model.get('display_label')
          enabled: model.get('ca_list_items.is_enabled', false) == '1'
          parentId: model.get('ca_list_items.parent_id', false)
          depth: model.get('depth')
        )

      if sort == true
        list = _.sortBy(
          list,
          (item) ->
            item.name?.toLowerCase()
          , 'desc'
        ).reverse()

      for listItem in list
        for resultItem, index in result
          if resultItem.id == listItem.parentId
            result.splice(index + 1, 0, listItem)
            continue

      if list.length == 0
        done = true

      depth++

    result








