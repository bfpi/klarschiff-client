class Service < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk

  def to_s
    service_name
  end

  def type
    keywords.split(';').first
  end
end
