module ResourceClient
  extend ActiveSupport::Concern

  class Config
    conf_file = File.join(Rails.root, %w(config resource_servers.yml))
    @@config = File.open(conf_file) { |file| YAML::load file }[Rails.env || 'development']
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
