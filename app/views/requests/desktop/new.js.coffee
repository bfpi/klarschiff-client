<% if params[:switch_type] -%>
KS.layers.findById('new_feature').getSource().getFeatures()[0].setStyle(KS.styles.newFeature("<%= @type %>"))
$('#type-select').replaceWith("<%= j render partial: 'requests/desktop/category_select', locals: { type: @type } %>")
<% else -%>
<% if @errors.present? -%>
$('.errors').replaceWith("<%= j render partial: 'application/desktop/errors' %>")
<% else -%>
KS.olMap.removeInteraction KS.newFeatureInteraction
KS.stopAnimationTimeout()
KS.layers.findById('new_feature').getSource().getFeatures()[0].set('animate', false)
$('.request-container').replaceWith("<%= j render partial: 'requests/desktop/new' %>")
<% end -%>
<% end -%>
