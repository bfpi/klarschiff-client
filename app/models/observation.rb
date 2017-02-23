class Observation < ActiveResource::Base
  include ResourceClient
  
  self.set_server_connection :city_sdk
end
