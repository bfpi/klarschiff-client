# frozen_string_literal: true

require 'English'
require 'English'
require 'English'
require 'English'
require 'English'
require 'English'
require 'open-uri'

class Coordinate
  attr_accessor :lat, :long, :result

  def initialize(lat, long)
    @lat = lat
    @long = long
    config = Settings::ResourceServer.city_sdk

    uri = URI.join(config[:site], 'coverage.json')
    uri.query = URI.encode_www_form(config.slice(:api_key).merge(lat: lat, long: long))

    begin
      response = uri.read('Accept-Charset' => 'UTF-8', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
    rescue Exception
      Rails.logger.error "Exception: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n  " << $ERROR_INFO.backtrace.join("\n  ")
      return true
    end

    @result = JSON.parse(response.force_encoding('UTF-8'))
  rescue Exception
    Rails.logger.error "Exception: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n  " << $ERROR_INFO.backtrace.join("\n  ")
  end

  def redirect_url
    @result['instance_url']
  end

  def covered_by_juristiction?
    @result['result']
  end
end
