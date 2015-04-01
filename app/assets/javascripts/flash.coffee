class KS.Flash
  constructor: ->
    @modal = $('div#flash.modal')

  show: (content) ->
    return unless  content?
    @modal.find('.modal-content').html(content)
    @modal.modal 'show'

$ ->
  KS.flash = new KS.Flash
  KS.flash.modal.on 'hidden.bs.modal', ->
    KS.nav.switchTo 'map'
