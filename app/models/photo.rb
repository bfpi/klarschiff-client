# frozen_string_literal: true

class Photo < ActiveResource::Base
  include ResourceClient
  set_server_connection :city_sdk
  self.prefix = File.join(site.path, '/requests/photos/:service_request_id')
end
