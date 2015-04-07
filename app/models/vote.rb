class Vote < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  self.prefix = "/requests/votes/:service_request_id"
end
