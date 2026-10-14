# frozen_string_literal: true

require 'test_helper'

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  test 'index renders the statistic with the counts of the requests' do
    mock_city_sdk :get, 'areas', [{ id: 1, name: 'Mitte' }]
    mock_city_sdk :get, 'requests', [{ count: 7 }]
    get '/statistics', xhr: true

    assert_includes response.body, 'KS.initializeHeatmap()'
    assert_includes response_text, '<option value="1">Mitte</option>'
    assert_includes response_text, '<span class="badge bg-warning">7</span>'
  end
end
