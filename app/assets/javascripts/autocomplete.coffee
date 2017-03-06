$ ->
  $("#places_search").autocomplete
    source: (request, response) ->
      $.ajax(
        url: '/places'
        dataType: 'json'
        data:
          pattern: request.term
        success: (data) ->
          response(data)
      )
    minLength: 2,
    select: (event, ui) ->
      $.get("/map?#{ ui.item.id.map( (obj) -> "bbox[]=#{ obj }").join('&') }",
      null, null, 'script')
      false
