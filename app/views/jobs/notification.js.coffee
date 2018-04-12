<% unless @difference.blank? -%>
  <% @difference.each do |job| %>
  KS.NotificationHandler().displayNotification(
    '<%= t('.notification_title', name: Settings::Client.name) %>',
    '#<%= job.id %> <%= job.service.group %> – <%= job.service_name %>',
    '<%= URI.join(root_url, image_path('klarschiff.png')) %>'
  )
  <% end %>
<% end -%>
