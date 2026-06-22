class Completion < ApplicationResource
  self.prefix = File.join(site.path, '/requests/completions/:service_request_id')
end
