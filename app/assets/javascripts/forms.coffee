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

  KS.content().on 'submit', 'form.fileupload', ->
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
