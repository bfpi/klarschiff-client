class Area < ActiveResource::Base
  include ResourceClient

  self.set_server_connection :city_sdk

  attr_accessor :id, :name, :grenze
end
