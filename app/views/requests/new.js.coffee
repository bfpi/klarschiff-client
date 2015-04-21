KS.clearNewFeature()
$('#ol-map > nav.navbar.actions').addClass('hidden')

KS.nav.switchTo 'request', '<%= j render("new") %>'
