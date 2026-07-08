# frozen_string_literal: true

require 'active_resource/base'
require 'active_resource/validations'

# Module to patch several CitySDK sepcific issues for ActiveResource
module ActiveresourceCitysdkStructurePatch
  # Patch to surface API validation errors as remote errors.
  module ValidationsWithCitySDKErrorResponseCodes
    def save(options = {})
      super
    rescue BadRequest, UnauthorizedAccess => e
      @remote_errors = e
      load_remote_errors(@remote_errors, true)
      false
    end
  end
  ActiveResource::Base.prepend ValidationsWithCitySDKErrorResponseCodes

  # Patch to normalize array-based payloads before ActiveResource loads them.
  module LoadWithCitySDKArrayStructure
    def load(attributes, remove_root = false, persisted = false) # rubocop:disable Style/OptionalBooleanParameter
      normalized_attributes = if attributes.is_a?(Array)
                                attributes.first
                              else
                                attributes
                              end
      normalized_attributes = {} unless normalized_attributes.respond_to?(:to_h)
      super(normalized_attributes.to_h, remove_root, persisted)
    end
  end
  ActiveResource::Base.prepend LoadWithCitySDKArrayStructure

  # Ensure find calls inherit the default query options.
  module FindWithExtendedDefaultQueryOptions
    def find(*args)
      scope = args.shift
      options = args.shift || {}
      (options[:params] ||= {}).merge!(default_query_options)
      super(scope, options)
    rescue ActiveResource::ResourceInvalid => e
      Rails.logger.error(e.message)
      raise
    end

    private

    def default_query_options
      @default_query_options ||= {}
      if (key = api_key) && @default_query_options[:api_key].blank?
        @default_query_options[:api_key] = key
      end
      @default_query_options
    end
  end
  ActiveResource::Base.singleton_class.prepend FindWithExtendedDefaultQueryOptions

  # Ensure collection paths use the CitySDK URL format when needed.
  module CollectionPathWithCitySDKUrlFormat
    def collection_path(prefix_options = {}, query_options = nil)
      if prefix_options.blank?
        super
      else
        check_prefix_options(prefix_options)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{format_extension}#{query_string(query_options)}"
      end
    end
  end
  ActiveResource::Base.singleton_class.prepend CollectionPathWithCitySDKUrlFormat

  # Patch to parse array-based error payloads from CitySDK.
  module ErrorsWithCitySDKArrayStructure
    def from_json(json, save_cache = false) # rubocop:disable Style/OptionalBooleanParameter
      decoded = parse_json_response(json)
      return super unless decoded.is_a?(Array) && decoded.first.is_a?(Hash)

      clear unless save_cache
      decoded.each do |error|
        add :base, error['description']
      end
    end

    private

    def parse_json_response(json)
      ActiveSupport::JSON.decode(json) || {}
    rescue StandardError
      {}
    end
  end
  ActiveResource::Errors.prepend ErrorsWithCitySDKArrayStructure

  # Patch to enrich ActiveResource request error handling for CitySDK responses.
  module ConnectionWithAdditionalRequestResponseRescues
    private

    def request(method, path, *arguments)
      super
    rescue ActiveResource::ResourceInvalid, ActiveResource::ForbiddenAccess => e
      enhance_error_with_base_object(e)
      raise e
    rescue ActiveResource::ServerError => e
      handle_server_error(e)
    end

    def enhance_error_with_base_object(error)
      error.define_singleton_method(:base_object_with_errors) do
        Base.new.tap { |base| base.load_remote_errors(self) }
      end
      Rails.logger.error("CitySDKError: #{error.base_object_with_errors.errors.full_messages.join(', ')}")
    end

    def handle_server_error(error)
      error.response.tap do |response|
        response.body = ActiveSupport::JSON.encode([{ errors: Rails.logger.error("CitySDKError: #{error}") }])
      end
    end
  end
  ActiveResource::Connection.prepend ConnectionWithAdditionalRequestResponseRescues
end
