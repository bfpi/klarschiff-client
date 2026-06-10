# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/autorun'
require 'minitest/mock'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    def setup
      # 1. Definiere die API-Antwort (Header und Body)
      @headers = { 'Accept' => 'application/json' }
      @response_body = [{ status: 404, error: 'Not Found' }].to_json

      # 2. Registriere den Mock für den GET-Request
      # Syntax: ActiveResource::HttpMock.respond_to { |mock| mock.get(path, request_headers, response_body, status_code) }
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/citysdk/services.json?api_key=1234567890abcdefghijklmnopqrstuv&extensions=true', @headers,
                 @response_body, 200
        mock.get '/citysdk/requests.json?api_key=1234567890abcdefghijklmnopqrstuv&detailed_status=RECEIVED%2C+IN_PROCESS%2C+PROCESSED%2C+REJECTED&extensions=true&keyword=problem%2C+idea&max_requests=6&with_picture=true',
                 @headers, @response_body, 200
      end
    end

    def teardown
      # Wichtig: Den Mock nach jedem Test leeren, um Seiteneffekte zu vermeiden
      ActiveResource::HttpMock.reset!
    end
  end
end
