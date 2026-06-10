class Observation < ActiveResource::Base
  include ResourceClient

  set_server_connection :city_sdk
end
