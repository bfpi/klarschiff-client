class Photo < ApplicationResource
  self.prefix = File.join(site.path, '/requests/photos/:service_request_id')
end
