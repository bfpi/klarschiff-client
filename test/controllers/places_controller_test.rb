# frozen_string_literal: true

require 'test_helper'
require 'open-uri'

class PlacesControllerTest < ActionDispatch::IntegrationTest
  FEATURES = [
    { type: 'Feature', properties: { _title_: 'Rostock, Hauptstraße', objektgruppe: 'Straße' },
      geometry: { type: 'Polygon', coordinates: [[[12.1, 54.1], [12.2, 54.1], [12.2, 54.2], [12.1, 54.2]]] } }
  ].freeze

  # Fake for the geocoder, which is requested with OpenURI
  class Geocoder
    attr_accessor :query, :options

    def initialize(body, error: nil)
      @body = body
      @error = error
    end

    def open(options)
      @options = options
      raise @error if @error

      Struct.new(:status, :read).new(%w[200 OK], @body.to_json)
    end
  end

  def with_geocoder(geocoder = Geocoder.new({ features: FEATURES }), &)
    parse = URI.method(:parse)
    URI.stub(:parse, ->(url) { url == Settings::AddressSearch.url ? geocoder : parse.call(url) }, &)
    geocoder
  end

  test 'index searches the address with the geocoder' do
    geocoder = with_geocoder { get '/places.json', params: { pattern: 'Hauptstraße' } }

    assert_equal({ 'key' => Settings::AddressSearch.api_key, 'query' => 'rostock Hauptstraße', 'type' => 'search',
                   'class' => 'address', 'shape' => 'bbox', 'out_epsg' => '3857', 'limit' => '5' },
      Rack::Utils.parse_query(geocoder.query))
    assert_equal [{ 'label' => 'Hauptstraße', 'bbox' => [12.1, 54.1, 12.2, 54.2], 'transform_bbox' => nil,
                    'feature_id' => nil }], response.parsed_body
  end

  test 'index finds requests by number' do
    mock_city_sdk :get, 'requests', [request_payload(53, lat: 54.1, long: 12.1)]
    with_geocoder(Geocoder.new({ features: [] })) { get '/places.json', params: { pattern: '53' } }

    assert_equal({ 'label' => 'Meldung #53', 'bbox' => [12.1, 54.1, 12.1, 54.1], 'transform_bbox' => true,
                   'feature_id' => 53 }, response.parsed_body.first)
    assert_equal({ 'api_key' => Request.api_key, 'detailed_status' => Settings::Map.default_requests_states,
                   'extensions' => 'true', 'service_request_id' => '53' }, city_sdk_query(:get, 'requests'))
  end

  test 'index remembers the pattern in the session' do
    with_geocoder { get '/places.json', params: { pattern: 'Hauptstraße' } }
    geocoder = with_geocoder { get '/places.json' }

    assert_equal 'rostock Hauptstraße', Rack::Utils.parse_query(geocoder.query)['query']
  end

  test 'index ignores geocoder errors' do
    error = OpenURI::HTTPError.new('500 Internal Server Error', StringIO.new)
    with_geocoder(Geocoder.new(nil, error: error)) { get '/places.json', params: { pattern: 'Hauptstraße' } }

    assert_response :success
    assert_empty response.parsed_body
  end

  test 'index returns no places without pattern' do
    get '/places.json'

    assert_equal 'null', response.body
  end

  test 'index renders the mobile results' do
    with_geocoder { get '/places', params: { pattern: 'Hauptstraße', mobile: 'true' }, xhr: true }

    assert_includes response.body, "KS.nav.switchTo('places'"
    assert_includes response_text, 'Hauptstraße'
  end

  test 'index renders the mobile auto completion' do
    with_geocoder { get '/places', params: { pattern: 'Hauptstraße', mobile: 'true', auto: 'true' }, xhr: true }

    assert_includes response.body, "$('#places_results').html("
  end

  test 'index is not acceptable as html' do
    get '/places'

    assert_response :not_acceptable
  end
end
