class Service < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk

  def to_s
    service_name
  end

  def type
    (t = keywords.split(';').first) && t == "idee" ? "idea" : t
  end
end
