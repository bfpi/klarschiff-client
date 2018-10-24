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

  module LoadWithCitySDKArrayStructure
    def load(attributes, remove_root = false, persisted = false)
      super attributes.is_a?(Array) ? attributes.first : attributes.to_h, remove_root, persisted
    end
  end

  class Base
    prepend ValidationsWithCitySDKErrorResponseCodes
    prepend LoadWithCitySDKArrayStructure

    module FindWithExtendedDefaultQueryOptions
      def find(*args)
        scope = args.slice!(0)
        options = args.slice!(0) || {}
        (options[:params] ||= {}).merge! default_query_options
        super scope, options
      rescue ActiveResource::ResourceInvalid => e
        Rails.logger.error e.message
        raise
      end
    end

    module CollectionPathWithCitySDKUrlFormat
      def collection_path(prefix_options = {}, query_options = nil)
        if prefix_options.blank?
          super prefix_options, query_options
        else
          check_prefix_options(prefix_options)
          prefix_options, query_options = split_options(prefix_options) if query_options.nil?
          "#{ prefix(prefix_options) }#{ format_extension }#{ query_string(query_options) }"
        end
      end
    end

    class << self
      prepend FindWithExtendedDefaultQueryOptions
      prepend CollectionPathWithCitySDKUrlFormat
      mattr_accessor :api_key

      def default_query_options
        @@default_query_options ||= {}
        if (key = api_key) && @@default_query_options[:api_key].blank?
          @@default_query_options[:api_key] = key
        end
        @@default_query_options
      end

      mattr_writer :default_query_options

    end
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
    rescue ResourceInvalid, ForbiddenAccess => e
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
