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
    minLength: 2
    select: (event, ui) ->
      $.get("/map?#{ ui.item.bbox.map( (obj) -> "bbox[]=#{ obj }").join('&') }",
      null, null, 'script')
      false

  $(document).on 'input', '#places-search-pattern', () ->
    elem = $(this)
    if elem.val().length == 0 || elem.val().length >= 3
      $.ajax(
        url: '/places'
        dataType: 'script'
        data:
          auto: true
          mobile: true
          pattern: elem.val()
      )