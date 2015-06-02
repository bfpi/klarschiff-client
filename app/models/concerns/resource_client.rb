module ResourceClient
  extend ActiveSupport::Concern

  module ClassMethods
    def set_server_connection(name)
      config = Settings::ResourceServer.send(name)
      raise "No resource server config found for '#{ name }'!" if config.blank?
      config.each do |param, value|
        self.send :"#{ param }=", value
      end
    end
  end
end
