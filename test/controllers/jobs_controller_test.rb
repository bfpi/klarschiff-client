# frozen_string_literal: true

require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest
  USER = { login: 'max', name: 'Max Muster', email: 'max@example.com', field_service_team: 'Team A' }.freeze
  LOGIN = { 'AUTHENTICATE_FULLNAME' => 'max' }.freeze

  def with_login(user = USER, &)
    mock_city_sdk :get, 'users', [user]
    Settings::Client.stub(:login_required, true, &)
  end

  def mock_jobs(*ids)
    mock_city_sdk(:get, 'requests', ids.map { |id| request_payload(id) })
  end

  test 'index requests the jobs of the field service team' do
    mock_jobs 53, 60
    with_login { get '/jobs.json', env: LOGIN }

    assert_equal [53, 60], response.parsed_body.pluck('service_request_id')
    assert_equal({ 'agency_responsible' => 'Team A', 'api_key' => Request.api_key,
                   'detailed_status' => Settings::Map.default_requests_states, 'extensions' => 'true' },
      city_sdk_query(:get, 'requests'))
  end

  %w[json js html].each do |format|
    test "index answers without content to users without field service team as #{format}" do
      with_login(USER.merge(field_service_team: nil)) { get "/jobs.#{format}", env: LOGIN, xhr: format == 'js' }

      assert_response :ok
      assert_empty response.body
      assert_empty city_sdk_requests(:get, 'requests')
    end
  end

  test 'index renders the jobs list' do
    mock_jobs 53
    with_login { get '/jobs', env: LOGIN, xhr: true }

    assert_includes response.body, 'KS.initializeJobsList()'
  end

  test 'notification reports new jobs only' do
    mock_jobs 53
    with_login { get '/jobs/notification', env: LOGIN, xhr: true }
    mock_jobs 53, 60
    with_login { get '/jobs/notification', env: LOGIN, xhr: true }

    assert_includes response.body, '#60 Gefahrenstellen'
    assert_not_includes response.body, '#53'
  end

  test 'update moves the job and saves the new order' do
    mock_jobs 53, 60, 61
    [53, 60, 61].each { |id| mock_city_sdk :patch, "requests/#{id}", [] }
    with_login { patch '/jobs/61', params: { index: 0 }, env: LOGIN }

    assert_equal(%w[0 1 2], [61, 53, 60].map { |id| city_sdk_query(:patch, "requests/#{id}")['job_priority'] })
    assert_equal 'max@example.com', city_sdk_query(:patch, 'requests/53')['email']
  end

  test 'login looks up the user from the single sign-on' do
    mock_jobs
    with_login { get '/jobs.json', env: LOGIN }

    assert_equal({ 'api_key' => User.api_key, 'login' => 'max' }, city_sdk_query(:get, 'users'))
  end

  test 'login with http basic authentication creates a session in the backoffice' do
    mock_jobs
    mock_city_sdk :post, 'users', USER, 201
    with_login { get '/jobs.json', headers: { 'HTTP_AUTHORIZATION' => basic_auth('max', 'geheim') } }

    assert_response :success
    assert_equal({ 'login' => 'max', 'password' => 'geheim', 'api_key' => User.api_key },
      city_sdk_body(:post, 'users'))
  end

  test 'login requests http basic authentication without credentials' do
    with_login { get '/jobs.json' }

    assert_response :unauthorized
  end

  test 'login rejects invalid credentials' do
    mock_city_sdk :post, 'users', [{ code: '401', description: 'Login fehlgeschlagen' }], 401
    with_login { get '/jobs.json', headers: { 'HTTP_AUTHORIZATION' => basic_auth('max', 'falsch') } }

    assert_response :unauthorized
  end

  def basic_auth(user, password)
    ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
  end
end
