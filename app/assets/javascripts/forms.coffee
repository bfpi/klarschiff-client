$ ->
  KS.content().on 'click', '.has-clear .form-control-clear', ->
    $(@).parents('.form-group').find('input').val ''
