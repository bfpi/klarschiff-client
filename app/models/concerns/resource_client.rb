module ResourceClient
  extend ActiveSupport::Concern

  class Config
    @@config = File.open(Rails.root.join('config', 'settings.yml')) { |file|
      YAML::load file }['resource_servers']
    def self.[](key)
      @@config[key.to_s]
    end
  end

  module ClassMethods
    def set_server_connection(name)
      config = ResourceClient::Config[name]
      raise "No resource server config found for '#{ name }'!" if config.blank?
      config.each do |param, value|
        self.send :"#{ param }=", value
      end
    end
  end
end
