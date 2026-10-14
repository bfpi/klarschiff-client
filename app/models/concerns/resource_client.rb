# frozen_string_literal: true

module ResourceClient
  extend ActiveSupport::Concern

  module ClassMethods
    mattr_accessor :api_key
    mattr_writer :default_query_options

    # Takes the connection settings from the resource server with the name in config/settings.yml
    def connects_to(name)
      config = Settings::ResourceServer.send(name)
      raise "No resource server config found for '#{name}'!" if config.blank?

      config.each do |param, value|
        send :"#{param}=", value
      end
    end
  end
end
