KS.clearNewFeature()
KS.reloadFeatures()
$('.request-container').replaceWith('<%= j render partial: "/application/desktop/create", locals: { path: @redirect, options: @options } %>')
