# frozen_string_literal: true

require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  def teardown
    super
    Service.instance_variable_set(:@collection, nil)
  end

  test 'collection is loaded on first use and kept' do
    Service.instance_variable_set(:@collection, nil)
    mock_city_sdk :get, 'services', [service_payload(4), service_payload(5)]

    assert_equal %w[4 5], Service.collection.map(&:service_code)
    assert_equal %w[4 5], Service.collection.map(&:service_code)
    assert_equal 1, city_sdk_requests(:get, 'services').size
  end

  test 'finds a service of the collection by its code' do
    assert_equal '4', Service[4].service_code
    assert_nil Service[99]
  end
end
