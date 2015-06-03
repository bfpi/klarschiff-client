class Note < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  self.prefix = File.join(site.path, "/requests/notes/:service_request_id")
end
