<% if @direct.present? -%>
coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], KS.projectionWGS84, KS.projection())
KS.olMap.getView().setZoom(11)
KS.olMap.getView().setCenter(coord)
<% end -%>
<% if @context == 'mobile' -%>
KS.nav.switchTo 'request', '<%= j render("requests/#{ context }/show") %>'
<% else -%>
$('.request-container').replaceWith('<%= j render partial: "requests/#{ context }/show" %>')
<% end -%>
