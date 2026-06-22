class Vote < ApplicationResource
  self.prefix = File.join(site.path, '/requests/votes/:service_request_id')
end
