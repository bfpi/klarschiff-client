coord = ol.proj.transform([<%= @request.long %>, <%= @request.lat %>], KS.projectionWGS84, KS.projection())
highlight_layer = KS.layers.findById('highlight_layer')
highlight_layer.getSource().clear()
icon = "<%= @request.icon_active_map %>"
KS.createHighlightFeature(highlight_layer, coord, icon)

<% if @direct.present? -%>
KS.olMap.getView().setZoom(11)
<% else -%>
KS.olMap.beforeRender(ol.animation.pan({ source: KS.olMap.getView().getCenter() }))
<% end -%>
KS.olMap.getView().setCenter(coord)

<% if @refresh -%>
KS.reloadFeatures()
KS.clearNewFeature()
<% end -%>

$('.sidebar-toggler').trigger('click') unless $('.sidebar').is(':visible')
if $('.request-container').prop('id') == 'request-form'
  $('.request-container').hide()
  partial = "<div class='request-container overlay'><%= j render partial: 'requests/desktop/show' %></div>"
  if $('.overlay').length > 0
    $('.overlay').replaceWith(partial)
  else
    $('#request.tab-pane').append(partial)
else
  $('.request-container').replaceWith("<%= j render partial: 'requests/desktop/show' %>")
