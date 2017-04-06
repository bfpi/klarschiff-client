<% if @cancel -%>
KS.clearNewFeature()
$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/start_request' %>")
<% else -%>
<% if @mobile -%>
KS.nav.switchTo 'map'

KS.layers.findById("features").setVisible(<%= @show_non_job_features %>)
<% end -%>

<% if @bbox.present? -%>
$('#places_search').val('')
extent = Array(<%= @bbox.join ', ' %>)
if extent[0] == extent[2] && extent[1] == extent[3]
  KS.olMap.getView().setCenter(extent)
  KS.olMap.getView().setZoom(KS.maxZoom - 1)
else
  KS.olMap.getView().fit(extent, KS.olMap.getSize())

if KS.layers.findById('new_feature')
  KS.moveNewFeature()
<% end -%>
<% end -%>
