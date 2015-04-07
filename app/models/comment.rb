class Comment < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  self.prefix = "/requests/comments/:service_request_id"
end
