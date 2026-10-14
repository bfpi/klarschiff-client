# frozen_string_literal: true

require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  # Fake for the PUT request to the backoffice, which is sent with Net::HTTP
  class Backoffice
    attr_reader :host, :port, :sent_request

    def initialize(body)
      @body = body
    end

    def call(host, port)
      @host = host
      @port = port
      self
    end

    def start
      yield self
    end

    def request(request)
      @sent_request = request
      Struct.new(:read_body).new(@body.to_json)
    end
  end

  def confirm(path, body)
    backoffice = Backoffice.new(body)
    Net::HTTP.stub(:new, backoffice.method(:call)) { get path }
    backoffice
  end

  test 'issue confirms the request' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    backoffice = confirm '/confirmations/abc/issue', { service_request_id: 53 }

    assert_equal(%w[PUT /citysdk/requests/abc/confirm.json], backoffice.sent_request.then { [it.method, it.path] })
    assert_equal [URI(Settings::ResourceServer.city_sdk[:site]).host, 3001], [backoffice.host, backoffice.port]
    assert_includes response.body, I18n.t('confirmations.confirm_success.accepted')
  end

  %w[vote abuse photo completion].each do |type|
    test "#{type} confirms the #{type}" do
      mock_city_sdk :get, 'requests/53', [request_payload]
      backoffice = confirm "/confirmations/abc/#{type}", { service_request_id: 53 }

      assert_equal "/citysdk/requests/#{type.pluralize}/abc/confirm.json", backoffice.sent_request.path
    end
  end

  test 'issue shows an error if the backoffice rejects the confirmation' do
    confirm '/confirmations/abc/issue', [{ code: '404', description: 'Nicht gefunden' }]

    assert_includes response.body, 'Ihre Bestätigung konnte leider nicht akzeptiert werden.'
  end

  test 'issue shows an error if the backoffice answers without content' do
    confirm '/confirmations/abc/issue', []

    assert_includes response.body, 'Ihre Bestätigung konnte leider nicht akzeptiert werden.'
  end

  test 'revoke_issue revokes the request' do
    backoffice = confirm '/confirmations/abc/revoke_issue', { service_request_id: 53 }

    assert_equal '/citysdk/requests/abc/revoke.json', backoffice.sent_request.path
    assert_includes response.body, I18n.t('confirmations.revoke_success.issue_deleted')
  end

  test 'revoke_issue shows an error if the backoffice rejects the revocation' do
    confirm '/confirmations/abc/revoke_issue', [{ code: '404', description: 'Nicht gefunden' }]

    assert_includes response.body, I18n.t('confirmations.revoke_error.error_message')
  end
end
