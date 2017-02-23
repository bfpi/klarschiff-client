coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], KS.projectionWGS84, KS.projection())
<% if @direct.present? -%>
KS.olMap.getView().setZoom(11)
KS.olMap.getView().setCenter(coord)
<% end -%>
<% if @refresh -%>
KS.clearNewFeature()
KS.reloadFeatures()
<% end -%>
highlight_layer = KS.layers.findById('highlight_layer')
highlight_layer.getSource().clear()
icon = "<%= @request.icon_active_map %>"
console.log(icon)
KS.createHighlightFeature(highlight_layer, coord, icon)
$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/show' %>")
