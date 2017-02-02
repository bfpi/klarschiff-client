<% if @direct.present? -%>
coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], KS.projectionWGS84, KS.projection())
KS.olMap.getView().setZoom(11)
KS.olMap.getView().setCenter(coord)
<% end -%>
$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/show' %>")
