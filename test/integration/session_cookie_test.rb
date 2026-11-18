# frozen_string_literal: true

require 'test_helper'

# Sichert Name und Pfad des Session-Cookies ab. Mehrere Client-Instanzen laufen unter
# demselben Hostnamen in unterschiedlichen Pfaden (z.B. / und /ppc) und duerfen sich
# ihre Sessions (inkl. CSRF-Token) nicht gegenseitig ueberschreiben.
class SessionCookieTest < ActionDispatch::IntegrationTest
  def setup
    super
    @forgery_protection = ActionController::Base.allow_forgery_protection
    # Mit aktivem CSRF-Schutz schreibt csrf_meta_tags das Token in die Session,
    # wodurch das Session-Cookie gesetzt wird.
    ActionController::Base.allow_forgery_protection = true
  end

  def teardown
    ActionController::Base.allow_forgery_protection = @forgery_protection
    super
  end

  test 'cookie name and path for the main client at root path' do
    assert_equal({ key: '_klarschiff_client_session', path: '/' }, SessionCookie.options('/'))
  end

  test 'cookie name and path when relative_url_root is not set' do
    assert_equal({ key: '_klarschiff_client_session', path: '/' }, SessionCookie.options(nil))
    assert_equal({ key: '_klarschiff_client_session', path: '/' }, SessionCookie.options(''))
  end

  test 'cookie name and path for a client in a sub path' do
    assert_equal({ key: '_klarschiff_client_ppc_session', path: '/ppc' }, SessionCookie.options('/ppc'))
  end

  test 'sub path is normalized regarding leading and trailing slashes' do
    expected = { key: '_klarschiff_client_ppc_session', path: '/ppc' }

    assert_equal expected, SessionCookie.options('/ppc/')
    assert_equal expected, SessionCookie.options('ppc')
  end

  test 'nested sub paths result in distinct cookie names' do
    assert_equal({ key: '_klarschiff_client_mv_ppc_session', path: '/mv/ppc' }, SessionCookie.options('/mv/ppc'))
  end

  test 'instances at different paths use different cookie names' do
    assert_not_equal SessionCookie.options('/')[:key], SessionCookie.options('/ppc')[:key]
  end

  test 'application is configured with the derived session cookie options' do
    assert_equal expected_options[:key], Rails.application.config.session_options[:key]
    assert_equal expected_options[:path], Rails.application.config.session_options[:path]
  end

  test 'response sets the session cookie with the derived name and path' do
    get '/map'

    assert_response :success
    cookie = session_cookie_header

    assert cookie, "no session cookie set, got: #{response.headers['set-cookie'].inspect}"
    assert_match(/;\s*path=#{Regexp.escape(expected_options[:path])}(;|\z)/i, cookie)
  end

  test 'legacy shared cookie name is no longer used' do
    get '/map'

    assert_not_includes Array.wrap(response.headers['set-cookie']).join("\n"), '_klarschiff-field_service_session'
  end

  private

  def session_cookie_header
    Array.wrap(response.headers['set-cookie']).flat_map { |h| h.split("\n") }
         .find { |c| c.start_with?("#{expected_options[:key]}=") }
  end

  def expected_options
    SessionCookie.options(Rails.application.config.relative_url_root)
  end
end
