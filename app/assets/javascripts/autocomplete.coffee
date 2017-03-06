$ ->
  $.widget 'ui.autocomplete', $.ui.autocomplete, _renderItem: (ul, item) ->
    value = @_super(ul, item)
    value

  autocomplete = ->
    $(".has-select[data-search-url][data-select-key]").each ->
      div = $(this)
      elem = div.find("input[type=text]")
      return if elem.hasClass('ui-autocomplete-input')
      searchUrl = div.data("search-url")
      selectUrl = div.data("select-url")
      key = div.data("select-key")
      elem.autocomplete
        source: (request, response, url) ->
          $.ajax(
            url: searchUrl
            dataType: 'json'
            data:
              pattern: request.term
            success: (data) ->
              response(data)
          )
        minLength: 3,
        select: (event, ui) ->
          joiner = if selectUrl.contains?("?") then "&" else "?"
          $.get("#{ selectUrl }#{ joiner }#{ ui.item.id.map( (obj) -> "#{ key }=#{ obj }").join('&') }")
          false

  $(document).ready(autocomplete)
  $(document).on('page:update', autocomplete)
  $(document).on('turbolinks:load', autocomplete)
