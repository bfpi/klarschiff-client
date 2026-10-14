# frozen_string_literal: true

require 'test_helper'

class CoordinateTest < ActiveSupport::TestCase
  # Fake for the coverage request to the backoffice, which is sent with OpenURI
  class Coverage
    attr_accessor :query
    attr_reader :site, :path, :options

    def initialize(body, error: nil)
      @body = body
      @error = error
    end

    def call(site, path)
      @site = site
      @path = path
      self
    end

    def read(options)
      @options = options
      raise @error if @error

      @body.to_json.dup.force_encoding('ASCII-8BIT')
    end
  end

  def coordinate(coverage)
    URI.stub(:join, coverage.method(:call)) { Coordinate.new(54.1, 12.1) }
  end

  test 'requests the coverage of the position' do
    coverage = Coverage.new({ result: true })
    coordinate(coverage)

    assert_equal [Settings::ResourceServer.city_sdk[:site], 'coverage.json'], [coverage.site, coverage.path]
    assert_equal({ 'api_key' => Settings::ResourceServer.city_sdk[:api_key], 'lat' => '54.1', 'long' => '12.1' },
      Rack::Utils.parse_query(coverage.query))
  end

  test 'reads the coverage with utf-8' do
    coordinate(Coverage.new({ result: true, instance_url: 'https://müritz.example' })).then do |coord|
      assert_predicate coord, :covered_by_juristiction?
      assert_equal 'https://müritz.example', coord.redirect_url
    end
  end

  test 'reports a position outside the jurisdiction' do
    assert_not coordinate(Coverage.new({ result: false })).covered_by_juristiction?
  end

  test 'logs errors of the coverage request' do
    coord = coordinate(Coverage.new(nil, error: SocketError.new('getaddrinfo failed')))

    assert_nil coord.result
  end
end
