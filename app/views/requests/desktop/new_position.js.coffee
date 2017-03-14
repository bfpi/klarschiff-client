$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/new_position_buttons' %>")
coord = null
if (arr = KS.newFeatureOverlay.getFeatures().getArray()).length > 0
  coord = arr[0].getGeometry().getCoordinates()
KS.createFeature 'blank', coord
