KS.reloadFeatures()
if $('.overlay').length > 0
  $('.overlay').replaceWith('<div class="request-container overlay"><%= j render partial: "application/desktop/create", locals: { path: @redirect, options: @options } %></div>')
else
  $('.request-container').replaceWith('<%= j render partial: "/application/desktop/create", locals: { path: @redirect, options: @options } %>')
