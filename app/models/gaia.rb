# frozen_string_literal: true

require 'open-uri'

class Gaia
  class << self
    def config
      @config ||= Settings::Gaia
    end

=begin
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
=end
    def search_places(pattern)
      request_features(pattern, config.type).each do |place|
        p place.inspect
        p Place.new({ "geometry"=>{"coordinates"=>[p.long, p.lat], "type"=>"Point", "transform_bbox" => true},
                    "properties"=>{ "_title_"=>"Meldung ##{ p.service_request_id }", "feature_id" => p.service_request_id },
                    "type"=>"Feature" })

      end
      # request_features(pattern, config.type).map { |p| Place.new(p).as_json }
    end
=begin
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
=end
    private

    def format_address(feature)
      addr = feature['strasse_name']
      addr << " #{feature['hausnummer']}" if feature['hausnummer'].present?
      addr << feature['hausnummer_zusatz'] if feature['hausnummer_zusatz'].present?
      addr << " (#{feature['gemeindeteil_name']})" if feature['gemeindeteil_name'].present?
      addr
    end

=begin
    def order_features(issue, search_class)
      return [] if (features = request_features(issue, search_class)).blank?
      features.pluck('properties').sort_by { |a| a['entfernung'] }
    end
=end

    def request_features(query, type)
      uri = URI.parse(config.url)
      uri.query = URI.encode_www_form(request_feature_params(query, type))
      request_and_parse_features uri
    end

    def request_feature_params(query, type)
      { q: query, type:, n: 5, crs: 'EPSG:4326' }
    end

    def request_and_parse_features(uri)
      p uri.inspect
      if (res = uri.open(request_uri_options)) && res.status.include?('OK')
        JSON.parse(res.read).try(:[], 'features')
      end
    rescue OpenURI::HTTPError
      Rails.logger.error "Gaia Error: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n"
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
