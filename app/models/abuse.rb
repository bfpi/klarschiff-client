class Abuse < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  self.prefix = "/requests/abuses/:service_request_id"
end
