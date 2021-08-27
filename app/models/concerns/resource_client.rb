module ResourceClient
  extend ActiveSupport::Concern

  module ClassMethods
    mattr_accessor :api_key
    mattr_writer :default_query_options

    def set_server_connection(name)
      config = Settings::ResourceServer.send(name)
      raise "No resource server config found for '#{ name }'!" if config.blank?
      config.each do |param, value|
        self.send :"#{ param }=", value
      end
    end
  end
end
