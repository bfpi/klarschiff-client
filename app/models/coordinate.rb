require 'open-uri'

class Coordinate
  attr_accessor :lat, :long

  def initialize(lat, long)
    @lat = lat
    @long = long
  end

  def covered_by_juristiction?
    config = Settings::ResourceServer.city_sdk

    uri = URI.join(config[:site], "coverage.json")
    uri.query = URI.encode_www_form(config.slice(:api_key).merge(lat: lat, long: long))

    begin
      response = uri.read('Accept-Charset' => 'UTF-8', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
    rescue Exception
      Rails.logger.error "Exception: #{ $!.inspect }, #{ $!.message }\n  " << $!.backtrace.join("\n  ")
      return true
    end

    JSON.parse(response.force_encoding('UTF-8'))['result']
  rescue Exception
    Rails.logger.error "Exception: #{ $!.inspect }, #{ $!.message }\n  " << $!.backtrace.join("\n  ")
  end
end
