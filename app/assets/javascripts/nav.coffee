class KS.Nav
  constructor: ->
    @bar = $('body > nav .nav')

  switchTo: (view, content) ->
    return unless view? && parent = KS.content()
    if view == 'map'
      KS.reloadFeatures()
      parent.hide()
      $('#ol-map').show()
      KS.olMap.updateSize()
    else
      $('#ol-map').hide()
      if content? && (div = KS.content(view))?
        div.replaceWith content
      else
        parent.append content

      parent.show().children("div.#{ view }").show().siblings().hide()


$ ->
  KS.nav = new KS.Nav

  KS.nav.bar.close= () ->
    if($('.navbar-toggle').css('display') != 'none')
      $(".navbar-toggle").trigger "click"

  KS.nav.bar.on 'click', 'a', ->
    KS.nav.bar.find('li').removeClass 'active'
    $(@).parent('li').addClass 'active'
    KS.nav.bar.close()

  KS.content().on 'click', '.clickable[data-target]', ->
    $.ajax
      url: $(@).data('target'),
      dataType: 'script'
