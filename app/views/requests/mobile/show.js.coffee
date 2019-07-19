<% if @direct.present? -%>
coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], KS.projectionWGS84, KS.projection())
KS.olMap.getView().setZoom(11)
KS.olMap.getView().setCenter(coord)
<% end -%>
KS.nav.switchTo 'request', '<%= j render("requests/mobile/show") %>'
new Shariff($('.shariff'), {});
$('#confirmation_foto_text_privacy_html, #new-photo input[type=submit]').hide()
