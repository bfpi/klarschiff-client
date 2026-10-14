# frozen_string_literal: true

require 'test_helper'

class AreasControllerTest < ActionDispatch::IntegrationTest
  test 'index requests the areas as json' do
    mock_city_sdk :get, 'areas', [{ id: 1, name: 'Mitte' }]
    get '/areas.json', params: { area_code: %w[1 2], with_districts: 'true', region: '13003', center: '54.1,12.1' }

    assert_equal [{ 'id' => 1, 'name' => 'Mitte' }], response.parsed_body
    assert_equal({ 'api_key' => Area.api_key, 'area_code' => '1, 2', 'with_districts' => 'true',
                   'search_class' => 'authority', 'regional_key' => '13003', 'center' => '54.1,12.1',
                   'limit' => Settings::Client.observations_area_limit.to_s }, city_sdk_query(:get, 'areas'))
  end

  test 'index requests the areas without filters' do
    mock_city_sdk :get, 'areas', []
    get '/areas.json'

    assert_equal({ 'api_key' => Area.api_key, 'area_code' => '',
                   'limit' => Settings::Client.observations_area_limit.to_s }, city_sdk_query(:get, 'areas'))
  end

  test 'index renders the district selection' do
    get '/areas', params: { context: 'districts' }, xhr: true

    assert_includes response.body, 'KS.createObservationFeatures'
  end

  test 'index renders the drawing of an area' do
    get '/areas', params: { context: 'draw' }, xhr: true

    assert_includes response.body, 'KS.setDrawObservation()'
  end

  test 'index requires a district from the form' do
    get '/areas', params: { context: 'districts', from_form: 'true' }, xhr: true

    assert_includes response_text, I18n.t('messages.errors.districts_required')
  end

  test 'index requires a drawn area from the form' do
    get '/areas', params: { context: 'draw', from_form: 'true' }, xhr: true

    assert_includes response_text, I18n.t('messages.errors.draw_required')
  end

  test 'index redirects to the new observation' do
    host! 'localhost:3000' # the redirect leads to Settings::Url.ks_server_url
    get '/areas', params: { context: 'districts', from_form: 'true', area_code: '1 2' }, xhr: true

    assert_redirected_to 'http://localhost:3000/observations/new?area_code=1+2'
  end

  test 'index is not acceptable as html' do
    get '/areas'

    assert_response :not_acceptable
  end
end
