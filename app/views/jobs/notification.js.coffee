<% unless @difference.blank? -%>
  <% @difference.each do |job| %>
  title = '<%= t('.notification_title', name: Settings::Client.name) %>'
  options =
    body: '#<%= job.id %> <%= job.service.group %> – <%= job.service_name %>'
    icon: '<%= URI.join(root_url, image_path('klarschiff.png')) %>'
  KS.ServiceWorkerRegistration.showNotification title, options
  <% end %>
<% end -%>
