KS.nav.bar.close()
KS.nav.switchTo 'map'
KS.map.actions().html('<%= j render("requests/mobile/new_position_buttons") %>').removeClass 'invisible'
KS.createFeature 'blank'
