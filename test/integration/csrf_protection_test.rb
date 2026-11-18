# frozen_string_literal: true

require 'test_helper'

# Absicherung der CSRF-Konfiguration (Code-Scanning-Alert #19, rb/csrf-protection-disabled).
#
# Die Testumgebung deaktiviert Forgery Protection global (config/environments/test.rb).
# Diese Tests schalten sie gezielt ein, um das Verhalten wie in Produktion zu pruefen:
# - Requests ohne/mit falschem Token werden abgelehnt (422), bevor Backend-Aufrufe erfolgen.
# - Legitime Requests (Formular-Token bzw. X-CSRF-Token-Header via jquery_ujs) funktionieren weiterhin.
# - Die Ablehnung greift auch bei Authentifizierung ueber HTTP Basic Auth (login_required),
#   wo :null_session keinen Schutz bietet, da die Credentials nicht in der Session liegen.
class CsrfProtectionTest < ActionDispatch::IntegrationTest
  API_KEY = '1234567890abcdefghijklmnopqrstuv'
  JSON_HEADERS = { 'Accept' => 'application/json' }.freeze
  CONTENT_HEADERS = { 'Content-Type' => 'application/json' }.freeze

  VOTE_PATH = '/citysdk/requests/votes/1.json'
  USER_PATH = '/citysdk/users.json'
  JOBS_PATH = "/citysdk/requests.json?agency_responsible=Team+A&api_key=#{API_KEY}" \
              '&detailed_status=RECEIVED%2C+IN_PROCESS&extensions=true'.freeze

  def setup
    super
    @forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    register_backend_mocks
  end

  def teardown
    ActionController::Base.allow_forgery_protection = @forgery_protection
    super
  end

  def register_backend_mocks
    ActiveResource::HttpMock.respond_to(false) do |mock|
      mock.post VOTE_PATH, CONTENT_HEADERS, { id: 1, service_request_id: 1 }.to_json, 201
      mock.post USER_PATH, CONTENT_HEADERS,
                { id: 7, login: 'aussendienst', email: 'ad@example.com', field_service_team: 'Team A' }.to_json, 201
      mock.get JOBS_PATH, JSON_HEADERS,
               [{ service_request_id: 1 }, { service_request_id: 2 }].to_json, 200
      [job_patch_path(2, 0), job_patch_path(1, 1)].each do |path|
        mock.patch path, CONTENT_HEADERS, nil, 200
      end
    end
  end

  # --- Konfiguration --------------------------------------------------------

  test 'ApplicationController raises on invalid CSRF tokens instead of nulling the session' do
    assert_equal ActionController::RequestForgeryProtection::ProtectionMethods::Exception,
                 ApplicationController.forgery_protection_strategy
  end

  test 'CSRF verification runs before authentication' do
    filters = ApplicationController._process_action_callbacks.select { |cb| cb.kind == :before }.map(&:filter)

    assert_includes filters, :verify_authenticity_token
    assert_includes filters, :authenticate
    assert_operator filters.index(:verify_authenticity_token), :<, filters.index(:authenticate)
  end

  # --- Anonymer Modus (login_required: false) -------------------------------

  test 'GET requests work without a token and expose the CSRF meta tag' do
    get map_path

    assert_response :success
    assert_predicate csrf_token_from(response.body), :present?
  end

  test 'vote without CSRF token is rejected before reaching the backend' do
    post request_votes_path(1), params: vote_params, xhr: true

    assert_response :unprocessable_content
    assert_no_backend_writes
  end

  test 'vote with forged CSRF token is rejected' do
    post request_votes_path(1), params: vote_params.merge(authenticity_token: 'forged'), xhr: true

    assert_response :unprocessable_content
    assert_no_backend_writes
  end

  test 'vote with valid form token (remote form) is accepted' do
    token = fetch_csrf_token
    post request_votes_path(1), params: vote_params.merge(authenticity_token: token), xhr: true

    assert_response :success
    assert_backend_request :post, VOTE_PATH
  end

  test 'vote with valid X-CSRF-Token header (jquery_ujs ajax) is accepted' do
    token = fetch_csrf_token
    post request_votes_path(1), params: vote_params, xhr: true, headers: { 'X-CSRF-Token' => token }

    assert_response :success
    assert_backend_request :post, VOTE_PATH
  end

  test 'valid token from foreign origin is rejected' do
    token = fetch_csrf_token
    post request_votes_path(1), params: vote_params, xhr: true,
                                headers: { 'X-CSRF-Token' => token, 'Origin' => 'https://attacker.example' }

    assert_response :unprocessable_content
    assert_no_backend_writes
  end

  test 'same origin behind TLS-terminating proxy is accepted when X-Forwarded-Proto is set' do
    token = fetch_csrf_token
    post request_votes_path(1), params: vote_params, xhr: true,
                                headers: { 'X-CSRF-Token' => token, 'Origin' => 'https://www.example.com',
                                           'X-Forwarded-Proto' => 'https' }

    assert_response :success
    assert_backend_request :post, VOTE_PATH
  end

  # --- Aussendienst-Modus (login_required: true, HTTP Basic Auth) -----------

  test 'job reordering without token is rejected even with valid basic auth credentials' do
    Settings::Client.stub(:login_required, true) do
      put job_path(1), params: { index: 1 }, xhr: true, as: :json, headers: basic_auth_header

      assert_response :unprocessable_content
      assert_no_backend_writes
      assert_not backend_request?(:post, USER_PATH), 'authentication must not run before the CSRF check'
    end
  end

  test 'job reordering with valid X-CSRF-Token header works with basic auth' do
    Settings::Client.stub(:login_required, true) do
      Settings::Map.stub(:default_requests_states, 'RECEIVED, IN_PROCESS') do
        token = fetch_csrf_token(headers: basic_auth_header)
        put job_path(1), params: { index: 1 }, xhr: true,
                         headers: basic_auth_header.merge('X-CSRF-Token' => token)

        assert_response :success
        # Job 1 wurde an Index 1 verschoben => neue Reihenfolge [2, 1]
        assert_backend_request :patch, job_patch_path(2, 0)
        assert_backend_request :patch, job_patch_path(1, 1)
      end
    end
  end

  private

  def vote_params
    { vote: { author: 'buerger@example.com', privacy_policy_accepted: '1', id_list: [1] } }
  end

  def job_patch_path(id, priority)
    "/citysdk/requests/#{id}.json?api_key=#{API_KEY}&email=ad%40example.com&job_priority=#{priority}"
  end

  def basic_auth_header
    { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('aussendienst', 'geheim') }
  end

  def fetch_csrf_token(headers: {})
    get map_path, headers: headers

    assert_response :success
    csrf_token_from(response.body).tap { |token| assert_predicate token, :present?, 'CSRF meta tag missing' }
  end

  def csrf_token_from(html)
    Nokogiri::HTML(html).at_css('meta[name="csrf-token"]')&.[]('content')
  end

  def backend_writes
    ActiveResource::HttpMock.requests.reject { |req| req.method == :get }
  end

  def backend_request?(method, path)
    ActiveResource::HttpMock.requests.any? { |req| req.method == method && req.path == path }
  end

  def assert_no_backend_writes
    assert_empty backend_writes, "unexpected backend writes: #{backend_writes.map { |r| "#{r.method} #{r.path}" }}"
  end

  def assert_backend_request(method, path)
    recorded = ActiveResource::HttpMock.requests.map { |r| "#{r.method} #{r.path}" }

    assert backend_request?(method, path), "expected #{method.upcase} #{path}, got #{recorded}"
  end
end
