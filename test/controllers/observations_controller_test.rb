# frozen_string_literal: true

require 'test_helper'

class ObservationsControllerTest < ActionDispatch::IntegrationTest
  SERVICES = { problem_service: %w[4 5], problem_service_sub: %w[6], idea_service: %w[7],
               idea_service_sub: %w[8] }.freeze

  test 'index renders the feed of an observation' do
    mock_city_sdk :get, 'requests', [request_payload(53, status_notes: 'In Arbeit', description: 'Loch & Riss')]
    get '/observations.xml', params: { observation_key: 'abc' }

    assert_equal({ 'api_key' => Request.api_key, 'extensions' => 'true', 'observation_key' => 'abc' },
      city_sdk_query(:get, 'requests'))
    assert_includes response.body, '<title>#53 Problem (Gefahrenstellen – bauliche Gefahrenstelle)</title>'
    assert_includes response.body, '<link>http://localhost:3000/map?request=53</link>'
  end

  test 'index renders the feed of all public requests' do
    mock_city_sdk :get, 'requests', []
    get '/observations.xml'

    assert_equal({ 'api_key' => Request.api_key, 'detailed_status' => 'RECEIVED, IN_PROCESS, PROCESSED, REJECTED',
                   'extensions' => 'true', 'keyword' => 'problem, idea' }, city_sdk_query(:get, 'requests'))
  end

  test 'index describes the requests in the feed' do
    mock_city_sdk :get, 'requests', [request_payload(53, media_url: 'http://example.com/foto.jpg')]
    get '/observations.xml'

    description = Nokogiri::XML(response.body).at('item description').text

    assert_includes description, '<b>Beschreibung:</b> Loch in der Straße<br>'
    assert_includes description, '<img alt="Foto" class="rounded img-fluid" src="http://example.com/foto.jpg" />'
  end

  test 'index shows the status notes in the feed' do
    mock_city_sdk :get, 'requests', [request_payload(53, status_notes: 'In Arbeit')]
    get '/observations.xml'

    assert_includes Nokogiri::XML(response.body).at('item description').text, '<b>Statusinformation:</b> In Arbeit<br>'
  end

  test 'index escapes the texts of the requests in the feed' do
    mock_city_sdk :get, 'requests', [request_payload(53, description: '<script>alert(1)</script>')]
    get '/observations.xml'

    assert_includes Nokogiri::XML(response.body).at('item description').text, '&lt;script&gt;alert(1)&lt;/script&gt;'
  end

  test 'new renders the form' do
    get '/observations/new', params: { area_code: '1 2' }, xhr: true

    assert_includes response.body, "$('.area-container').replaceWith"
  end

  test 'create requires a service' do
    post '/observations', params: { area_code: '1 2' }, xhr: true

    assert_includes response_text, I18n.t('messages.errors.services_required')
    assert_empty city_sdk_requests(:post, 'observations')
  end

  test 'create posts the observation' do
    mock_city_sdk :post, 'observations', { rss_id: 'abc' }, 201
    post '/observations', params: SERVICES.merge(area_code: '1 2', geometry: 'POLYGON'), xhr: true

    assert_equal({ 'area_code' => '1, 2', 'geometry' => 'POLYGON', 'problems' => true, 'problem_service' => '4, 5',
                   'problem_service_sub' => '6', 'ideas' => true, 'idea_service' => '7', 'idea_service_sub' => '8' },
      city_sdk_body(:post, 'observations'))
  end

  test 'create posts an observation without ideas' do
    mock_city_sdk :post, 'observations', { rss_id: 'abc' }, 201
    post '/observations', params: { problem_service_sub: %w[6], geometry: 'POLYGON' }, xhr: true

    assert_equal({ 'geometry' => 'POLYGON', 'problems' => true, 'problem_service_sub' => '6', 'ideas' => false },
      city_sdk_body(:post, 'observations'))
  end

  test 'create links the feed of the observation' do
    mock_city_sdk :post, 'observations', { rss_id: 'abc' }, 201
    post '/observations', params: SERVICES.merge(area_code: '1 2'), xhr: true

    assert_includes response_text, 'href="/observations.xml?observation_key=abc"'
  end
end
