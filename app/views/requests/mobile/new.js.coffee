KS.clearNewFeature()
KS.map.actions().addClass 'hidden'
KS.nav.switchTo 'request', '<%= j render("requests/mobile/new") %>'
