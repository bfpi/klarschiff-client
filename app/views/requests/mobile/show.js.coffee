<% if params[:mobile_popup].present? -%>
coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], KS.projectionWGS84, KS.projection())
highlight_layer = KS.layers.findById('highlight_layer')
highlight_layer.getSource().clear()
icon = "<%= @request.icon_active_map %>"
KS.createHighlightFeature(highlight_layer, coord, icon)

KS.popupContent.innerHTML = '<%= j render("requests/mobile/popup") %>'
<% else -%>
<% if @direct.present? -%>
coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], KS.projectionWGS84, KS.projection())
KS.olMap.getView().setZoom(11)
KS.olMap.getView().setCenter(coord)
<% end -%>
KS.nav.switchTo 'request', '<%= j render("requests/mobile/show") %>'
$('#confirmation_foto_text_privacy_html, #new-photo input[type=submit]').hide()
KS.olMiniMap = new KS.MiniMap
<% end -%>
