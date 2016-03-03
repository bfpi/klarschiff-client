<% if @direct.present? -%>
console.log("Test")
coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], 'EPSG:4326', 'EPSG:25833')
KS.olMap.getView().setZoom(11)
KS.olMap.getView().setCenter(coord)
<% end -%>
KS.nav.switchTo 'request', '<%= j render("show") %>'
