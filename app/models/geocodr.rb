# frozen_string_literal: true

require 'open-uri'

class Geocodr
  class << self
    def config
      @config ||= Settings::Geocodr
    end

    def address(issue)
      order_features(issue, config.address_search_class).select do |feature|
        next if feature['objektgruppe'] != config.address_object_group
        return format_address(feature)
      end
      I18n.t 'geocodr.no_match'
    end

    def address_dms(issue)
      order_features(issue, config.address_search_class).select do |feature|
        next if feature['objektgruppe'] != config.address_object_group
        return feature
      end
      I18n.t 'geocodr.no_match'
    end

    def parcel(issue)
      order_features(issue, config.parcel_search_class).map do |feature|
        next if feature['objektgruppe'] != config.parcel_object_group
        return feature['flurstueckskennzeichen']
      end
      I18n.t 'geocodr.no_match'
    end

    def property_owner(issue)
      order_features(issue, config.property_owner_search_class).map do |feature|
        next if feature['objektgruppe'] != config.property_owner_object_group
        return feature['eigentuemer']
      end
      I18n.t 'geocodr.no_match'
    end

    def search_places(pattern)
      query = "#{Settings::Geocodr.try :localisator} #{pattern}".strip
      request_features(query, config.places_search_class, type: :search, shape: :bbox).map { |p| Place.new(p).as_json }
    end

    def find(address)
      request_features(address, config.places_search_class, type: :search, out_epsg: 4326)
    end

    def valid?(address)
      return false unless address =~ /(\d{5})/
      attr = { zip: Regexp.last_match(1) }
      address.delete! Regexp.last_match(1), ','
      return false unless address =~ /([a-zA-Zß .]*)\s(\d*)([a-zA-Z ]*)/
      attr.merge street: Regexp.last_match(1), no: Regexp.last_match(2), no_addition: Regexp.last_match(3)
    end

    private

    def format_address(feature)
      addr = feature['strasse_name']
      addr << " #{feature['hausnummer']}" if feature['hausnummer'].present?
      addr << feature['hausnummer_zusatz'] if feature['hausnummer_zusatz'].present?
      addr << " (#{feature['gemeindeteil_name']})" if feature['gemeindeteil_name'].present?
      addr
    end

    def order_features(issue, search_class)
      return [] if (features = request_features(issue, search_class)).blank?
      features.pluck('properties').sort_by { |a| a['entfernung'] }
    end

    def request_features(issue, search_class, type: :reverse, shape: nil, out_epsg: nil)
      uri = URI.parse(config.url)
      query = issue
      query = [issue.position.x, issue.position.y].join(',') if issue.respond_to?(:position) && issue.position.present?
      uri.query = URI.encode_www_form(request_feature_params(query, type, search_class, shape, out_epsg))
      request_and_parse_features uri
    end

    def request_feature_params(query, type, search_class, shape, out_epsg)
      uri_params = { key: config.api_key, query:, type:, class: search_class, in_epsg: 4326, limit: 5 }
      uri_params[:shape] = shape if shape.present?
      uri_params[:out_epsg] = out_epsg if out_epsg.present?
      uri_params
    end

    def request_and_parse_features(uri)
      if (res = uri.open(request_uri_options)) && res.status.include?('OK')
        JSON.parse(res.read).try(:[], 'features')
      end
    rescue OpenURI::HTTPError
      Rails.logger.error "Geocodr Error: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n"
      Rails.logger.error $ERROR_INFO.backtrace.join("\n  ")
      nil
    end

    def request_uri_options
      uri_options = { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
      uri_options[:proxy] = URI.parse(config.proxy) if config.respond_to?(:proxy) && config.proxy.present?
      uri_options
    end
  end
end
