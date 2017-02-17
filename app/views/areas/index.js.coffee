<% if @show_districts -%>
KS.layers.findById('observations').setVisible(true)
$('.area-container').replaceWith("<%= j render partial: 'districts_form' %>")
<% end -%>
<% if @cancel -%>
KS.layers.findById('observations').setVisible(false)
KS.resetSelectedFeatures()
$('.area-container').replaceWith("<%= j render partial: 'index' %>")
<% end -%>
