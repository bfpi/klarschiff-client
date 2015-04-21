
$('#ol-map > nav.navbar.actions').html('<%= j render("positioning_buttons") %>').removeClass('hidden')

$('#ol-map > nav.navbar.actions a.describe').on( "click", ->
  if KS.newFeatureOverlay.getFeatures().getArray().length > 0
    $.ajax
      url: '<%= new_request_path %>',
      data:
        typ: '<%= params[:type] %>'
        position: KS.newFeatureOverlay.getFeatures().getArray()[0].getGeometry().transform(KS.projection(), KS.projectionWGS84).flatCoordinates
      dataType: 'script'
  return false
)

$('#ol-map > nav.navbar.actions a.cancel').on( "click", ->
  KS.clearNewFeature()
  $('#ol-map > nav.navbar.actions').addClass('hidden')
  return false
)

KS.createFeature('<%= params[:type] %>')
KS.nav.bar.close()