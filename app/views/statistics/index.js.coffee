
$('.static-overlay .static-overlay-content').html('<%= j render(partial: "index").html_safe %>')
$('.static-overlay').show()
$('.sidebar .tab-content > *').removeClass('active')
$('.sidebar .tab-content .static').html('<%= j render(partial: "shared/statistic", locals: { css_col: 'col-12' }).html_safe %>')
$('.sidebar .tab-content .static').addClass('active')
KS.initializeHeatmap()
