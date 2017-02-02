$ ->
  KS.content().on 'click', '.has-clear .form-control-clear', ->
    $(@).parents('.form-group').find('input').val ''

  KS.content().on 'change', 'select[data-update]', ->
    if (target = $("##{ $(@).data('update') }"))? && (url = target.data('src'))?
      $.ajax(url: url, dataType: 'json', data: category: $(@).val()).done (response) ->
        target.html('').append "<option disabled='disabled' selected='selected' class='placeholder'>#{
          target.data('placeholder') }</option>"
        $(response).each ->
          target.append "<option value='#{ @service_code }'>#{ @service_name }</option>"

  $(document).on 'click', '.radio-type', ->
    url = $(@).parents('.radio-btns').data('url')
    console.log($(@))
    $.get(url + '&type=' + $(@).val(), null, null, 'script')

  KS.content().on 'submit', 'form.fileupload', (e) ->
    err = []
    $(e.target).find(':input[data-missing-message]').each ->
      if $(this).val() == null or $(this).val().length == 0
        err.push('<p>' + $(this).data('missing-message') + '</p>')

    if err.length > 0
      $.unique(err)
      content = '<div class="modal-header text-warning"><span class="glyphicon glyphicon-alert"></span>'
      content += $(e.target).data('validation-error-headline') + '</div>';
      content += '<div class="modal-body">' + err + '</div>'
      content += '<div class="modal-footer"><button type="button" class="btn';
      content += ' btn-primary" data-dismiss="modal">Ok</button></div>'
      KS.flash.show(content)
      e.preventDefault()
    else
      $(@).ajaxSubmit dataType: 'script'

    return false

  KS.content().on 'click', 'form .category a[data-action]', ->
    if $(@).data('action') == 'show'
      category = $($(@).attr('href')).removeClass('hidden').find('select').first()
      category.val category.children(':first').val()
    else
      $($(@).attr('href')).addClass('hidden').find('select').val null
    return false

  KS.content().on 'click', 'form .more_attachment a', ->
    $('#attachments').append($('#attachment-prototype').children().clone())
