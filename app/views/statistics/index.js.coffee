$('.statistic-overlay').show()
$('.static-overlay').hide()

if $('.statistic-overlay .overlay-content').html().length == 0
  $('.statistic-overlay .overlay-content').html('<%= j render(partial: "index").html_safe %>')
  KS.initializeHeatmap()

$('.sidebar .tab-content > *').removeClass('active')
$('.sidebar .tab-content .static').html('<%= j render(partial: "shared/statistic", locals: { css_col: 'col-12' }).html_safe %>')
$('.sidebar .tab-content .static').addClass('active')
