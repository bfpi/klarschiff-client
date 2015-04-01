require 'active_resource/base'
require 'active_resource/validations'

module ActiveResource
  class Base
    class << self
      mattr_accessor :api_key

      def default_query_options
        @@default_query_options ||= {}
        if (key = api_key) && @@default_query_options[:api_key].blank?
          @@default_query_options[:api_key] = key
        end
        @@default_query_options
      end

      mattr_writer :default_query_options

      def find_with_extended_default_query_options(*args)
        scope = args.slice!(0)
        options = args.slice!(0) || {}
        (options[:params] ||= {}).merge! default_query_options
        find_without_extended_default_query_options scope, options
      rescue ActiveResource::ResourceInvalid => e
        Rails.logger.error e.message
        raise
      end

      alias_method_chain :find, :extended_default_query_options
    end

    def load_with_citysdk_array_structure(attributes, remove_root = false, persisted = false)
      load_without_citysdk_array_structure attributes.is_a?(Array) ?
        attributes.first : attributes, remove_root, persisted
    end

    alias_method_chain :load, :citysdk_array_structure
  end

  class Errors
    def from_json_with_citysdk_array_structure(json, save_cache = false)
      decoded = ActiveSupport::JSON.decode(json) || {} rescue {}
      if decoded.kind_of?(Array) && decoded.first.kind_of?(Hash)
        clear unless save_cache
        decoded.each { |error|
          self[:base] << error['description']
        }
      else
        from_json_without_citysdk_structure json, save_cache
      end
    end

    alias_method_chain :from_json, :citysdk_array_structure
  end
end
