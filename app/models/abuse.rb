# frozen_string_literal: true

class Abuse < ActiveResource::Base
  include ResourceClient
  set_server_connection :city_sdk
  self.prefix = File.join(site.path, '/requests/abuses/:service_request_id')
end
