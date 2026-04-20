$('.sidebar .tab-content > *').removeClass('active')
$('.static-overlay .overlay-content').html('<%= j render(file: "#{Settings::Client.resources_path}/#{@file_name}.html").html_safe %>')
$('.statistic-overlay').hide()
$('.static-overlay').show()
