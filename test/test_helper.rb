# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/autorun'
require 'minitest/mock'

# Helpers for faking the CitySDK interface of the Klarschiff backoffice with ActiveResource::HttpMock
module CitySdkTestHelper
  # Answers every request to the resource, independent of the query string.
  def mock_city_sdk(method, resource, body = nil, status = 200)
    ActiveResource::HttpMock.respond_to(false) do |mock|
      mock.send(method, "/citysdk/#{resource}.json", {}, body&.to_json, status, {}, omit_query_in_path: true)
    end
  end

  # Answers with a real Net::HTTP response, for code checking the response class (e.g. Net::HTTPCreated)
  def mock_city_sdk_http(method, resource, response_class, body)
    response = response_class.new('1.1', Net::HTTPResponse::CODE_TO_OBJ.key(response_class), '')
    response.instance_variable_set(:@body, body.to_json)
    response.instance_variable_set(:@read, true)
    request = ActiveResource::Request.new(method, "/citysdk/#{resource}.json", nil, {}, omit_query_in_path: true)
    ActiveResource::HttpMock.respond_to({ request => response }, false)
  end

  def city_sdk_requests(method, resource)
    ActiveResource::HttpMock.requests.select do |req|
      req.method == method && req.path.split('?').first == "/citysdk/#{resource}.json"
    end
  end

  # Query parameters of the last request to the resource
  def city_sdk_query(method, resource)
    req = city_sdk_requests(method, resource).last
    assert req, "no #{method.upcase} request to #{resource}.json"
    Rack::Utils.parse_query(URI(req.path).query)
  end

  # Body of the last request to the resource
  def city_sdk_body(method, resource)
    req = city_sdk_requests(method, resource).last
    assert req, "no #{method.upcase} request to #{resource}.json"
    JSON.parse(req.body)
  end

  REQUEST_PAYLOAD = {
    status_notes: nil, status: 'reviewed', service_code: 4, service_name: 'bauliche Gefahrenstelle',
    description: 'Loch in der Straße', agency_responsible: 'Tiefbauamt', service_notice: nil,
    requested_datetime: '2021-07-26T08:20:45.989+02:00', updated_datetime: '2021-08-19T09:41:08.065+02:00',
    expected_datetime: nil, address: 'Klingbergstr. 51', lat: 53.370759951799506, long: 11.656640325601446,
    media_url: nil, zipcode: nil,
    extended_attributes: {
      detailed_status: 'RECEIVED', detailed_status_datetime: nil, description_public: false, expected_closure: nil,
      votes: 0, priority: 1, media_urls: nil, photo_required: false, trust: 0
    }
  }.freeze
  SERVICE_PAYLOAD = {
    service_name: 'bauliche Gefahrenstelle', group: 'Gefahrenstellen', group_id: 1, keywords: 'problem',
    type: 'realtime', description: nil, metadata: false, photo_requested: false
  }.freeze

  def request_payload(id = 53, **attributes)
    REQUEST_PAYLOAD.merge(service_request_id: id).deep_merge(attributes)
  end

  def service_payload(code = 4, **attributes)
    SERVICE_PAYLOAD.merge(service_code: code.to_s).merge(attributes)
  end
end

# Helpers for the responses of remote (JS) requests
module JsResponseTestHelper
  # JS responses embed escaped HTML, so tests compare the unescaped text.
  def response_text
    CGI.unescapeHTML(response.body.gsub('\\"', '"').gsub('\\/', '/').gsub('\\n', "\n"))
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) { include JsResponseTestHelper }

module ActiveSupport
  class TestCase
    include CitySdkTestHelper

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    def setup
      ActiveResource::HttpMock.reset!
      # Service.collection is loaded only once per process, so every test answers with the same services.
      mock_city_sdk :get, 'services', [service_payload]
    end

    def teardown
      # Wichtig: Den Mock nach jedem Test leeren, um Seiteneffekte zu vermeiden
      ActiveResource::HttpMock.reset!
    end
  end
end
