class Abuse < ApplicationResource
  self.prefix = File.join(site.path, '/requests/abuses/:service_request_id')
end
