# frozen_string_literal: true

require 'open-uri'

class Coordinate
  attr_accessor :lat, :long, :result

  def initialize(lat, long)
    @lat = lat
    @long = long
    @result = JSON.parse(read_coverage.force_encoding('UTF-8'))
  rescue StandardError => e
    Rails.logger.error "Exception: #{e.inspect}, #{e.message}\n  #{e.backtrace&.join("\n  ")}"
  end

  def redirect_url
    @result['instance_url']
  end

  def covered_by_juristiction?
    @result['result']
  end

  private

  def read_coverage
    config = Settings::ResourceServer.city_sdk
    uri = URI.join(config[:site], 'coverage.json')
    uri.query = URI.encode_www_form(config.slice(:api_key).merge(lat: lat, long: long))
    uri.read('Accept-Charset' => 'UTF-8', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
  end
end
