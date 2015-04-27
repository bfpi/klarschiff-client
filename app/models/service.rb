class Service < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  
  cattr_reader :collection, instance_reader: false do
    Service.all
  end

  alias_attribute :category, :group

  def self.[](code)
    collection.find { |s| s.service_code == code.to_i }
  end

  def to_s
    service_name
  end

  def type
    (t = keywords.split(';').first) && t == "idee" ? "idea" : t
  end

  def as_json(options = {})
    super options.merge(only: [:service_code, :service_name], methods: [:type, :category])
  end
end
