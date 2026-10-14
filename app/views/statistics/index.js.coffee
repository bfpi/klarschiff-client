$('.statistic-overlay').show()
$('.static-overlay').hide()

if $('.statistic-overlay .overlay-content').html().length == 0
  $('.statistic-overlay .overlay-content').html('<%= j render(partial: "index") %>')
  KS.initializeHeatmap()

$('.sidebar .tab-content > *').removeClass('active')
statistic = '<%= j render(partial: "shared/statistic", locals: { css_col: "col-12" }) %>'
$('.sidebar .tab-content .static').html(statistic)
$('.sidebar .tab-content .static').addClass('active')
