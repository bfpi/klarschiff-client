$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/new_position_buttons' %>")
coord = null
if (layer = KS.layers.findById('new_feature')) && (features = layer.getSource().getFeatures()).length > 0
  coord = features[0].getGeometry().getCoordinates()
KS.createFeature 'blank', coord
