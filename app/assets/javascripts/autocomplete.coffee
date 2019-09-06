$ ->
  $("#places_search").autocomplete
    source: (request, response) ->
      $.ajax(
        url: '/places'
        dataType: 'json'
        data:
          pattern: request.term
        success: (data) ->
          $(data).each (ix, entry) ->
            if entry.transform_bbox
              entry.bbox = ol.proj.transformExtent(entry.bbox, KS.projectionWGS84, KS.projection())
          response(data)
      )
    delay: 800
    minLength: 3
    select: (event, ui) ->
      $.get("/map?#{ ui.item.bbox.map( (obj) -> "bbox[]=#{ obj }").join('&') }",
      null, null, 'script').done ->
        if ui.item.feature_id != null && ui.item.feature_id != undefined
          url = KS.requests_path
          url += ui.item.feature_id
          url += "#{ if url.contains?('?') then '&' else '?' }mobile=" + KS.getUrlParam("mobile") if KS.getUrlParam("mobile")
          $.ajax(url: url, dataType: 'script')
      false

  $(document).on 'input', '#places-search-pattern', () ->
    elem = $(this)
    clearTimeout @searching
    @searching = setTimeout((->
      if elem.val().length == 0 || elem.val().length >= 3
        $.ajax(
          url: '/places'
          dataType: 'script'
          data:
            auto: true
            mobile: true
            pattern: elem.val()
        )
    ), 2000)