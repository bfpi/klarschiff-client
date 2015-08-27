class KS.Flash
  constructor: ->
    @modal = $('div#flash.modal')

  show: (content, target) ->
    return unless content?
    if target?
      @modal.data 'target', target
    else
      @modal.removeData 'target'
    @modal.find('.modal-content').html(content)
    @modal.modal 'show'

$ ->
  KS.flash = new KS.Flash

  KS.flash.modal.on 'show.bs.modal', ->
    if $(window).width() < 600
      $(@).children('.modal-dialog').addClass 'modal-sm'

  KS.flash.modal.on 'shown.bs.modal', ->
    setTimeout ( ->
        $('div#flash.modal').modal 'hide'
    ), 2000

  KS.flash.modal.on 'hidden.bs.modal', ->
    $(@).children('.modal-dialog').removeClass 'modal-sm'
    if target = $(@).data('target')
      $.ajax
        url: target,
        dataType: 'script'
