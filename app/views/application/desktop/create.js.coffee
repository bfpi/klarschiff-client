KS.reloadFeatures()
created = '<%= j render partial: "application/desktop/create", locals: { path: @redirect, options: @options } %>'
if $('.overlay').length > 0
  $('.overlay').replaceWith('<div class="request-container overlay">' + created + '</div>')
else
  $('.request-container').replaceWith(created)
