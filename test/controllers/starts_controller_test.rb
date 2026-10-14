# frozen_string_literal: true

require 'test_helper'

class StartsControllerTest < ActionDispatch::IntegrationTest
  test 'recent_requests renders the latest requests with picture' do
    mock_city_sdk :get, 'requests', [request_payload(53, media_url: 'http://example.com/foto.jpg')]
    get '/start/recent_requests', xhr: true

    assert_includes response.body, "$('.static-overlay').show()"
    assert_includes response_text, "background-image: url('http://example.com/foto.jpg')"
    assert_equal({ 'api_key' => Request.api_key, 'detailed_status' => 'RECEIVED, IN_PROCESS, PROCESSED, REJECTED',
                   'extensions' => 'true', 'keyword' => 'problem, idea', 'max_requests' => '6',
                   'with_picture' => 'true' }, city_sdk_query(:get, 'requests'))
  end
end
