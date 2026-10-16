# frozen_string_literal: true

require 'open-uri'

class Geocoder
  class << self
    def search(pattern)
      features(type: config.result_classes, q: pattern, crs: 'EPSG:3857', n: 5)
    end

    def reverse(long, lat)
      features(type: 'Adresse', coord: "#{long},#{lat}", crs: 'EPSG:4326', rm: 100, sort: 'dist', n: 1).first
    end

    private

    def features(params)
      res = uri(params).open(open_options)
      return [] unless res.status.include?('OK')

      JSON.parse(res.read).fetch('features', [])
    rescue OpenURI::HTTPError
      Rails.logger.error "Geocoding error: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n"
      Rails.logger.error $ERROR_INFO.backtrace.join("\n  ")
      []
    end

    def uri(params)
      URI.parse(config.url).tap { |uri| uri.query = URI.encode_www_form(params.merge(filter_params)) }
    end

    def filter_params
      return {} if (filter = config.localisator).blank?

      key, value = filter.delete_prefix('[').split(']=', 2)
      { "x_filter[#{key}]" => value }
    end

    def open_options
      options = { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
      options[:proxy] = URI.parse(config.proxy) if config.respond_to?(:proxy) && config.proxy.present?
      options
    end

    def config
      Settings::AddressSearch
    end
  end
end
