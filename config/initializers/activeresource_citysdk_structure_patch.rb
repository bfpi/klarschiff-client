require 'active_resource/base'
require 'active_resource/validations'

module ActiveResource
  module ValidationsWithCitySDKErrorResponseCodes
    def save(options = {})
      super
    rescue BadRequest, UnauthorizedAccess => error
      @remote_errors = error
      load_remote_errors(@remote_errors, true)
      false
    end
  end

  class Base
    prepend ValidationsWithCitySDKErrorResponseCodes

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

      def collection_path_with_citysdk_url_format(prefix_options = {}, query_options = nil)
        if prefix_options.blank?
          collection_path_without_citysdk_url_format prefix_options, query_options
        else
          check_prefix_options(prefix_options)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "#{ prefix(prefix_options) }#{ format_extension }#{ query_string(query_options) }"
        end
      end

      alias_method_chain :collection_path, :citysdk_url_format
    end

    def load_with_citysdk_array_structure(attributes, remove_root = false, persisted = false)
      load_without_citysdk_array_structure attributes.is_a?(Array) ?
        attributes.first : attributes, remove_root, persisted
    end

    alias_method_chain :load, :citysdk_array_structure
  end

  module ErrorsWithCitySDKArrayStructure
    def from_json(json, save_cache = false)
      decoded = ActiveSupport::JSON.decode(json) || {} rescue {}
      if decoded.kind_of?(Array) && decoded.first.kind_of?(Hash)
        clear unless save_cache
        decoded.each { |error|
          self[:base] << error['description']
        }
      else
        super
      end
    end
  end

  Errors.prepend ErrorsWithCitySDKArrayStructure

  module ConnectionWithAdditionalRequestResponseRescues
    private
    def request(method, path, *arguments)
      super
    rescue ResourceInvalid => e
      def e.base_object_with_errors
        Base.new.tap { |b| b.load_remote_errors self }
      end
      Rails.logger.error "CitySDKError: " << e.base_object_with_errors.errors.full_messages.join(', ')
      raise e
    rescue ServerError => e
      e.response.tap { |r| 
        r.body = ActiveSupport::JSON.encode([{ errors: Rails.logger.error("CitySDKError: #{ e }") }])
      }
    end
  end

  Connection.prepend ConnectionWithAdditionalRequestResponseRescues
end
