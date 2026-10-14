# frozen_string_literal: true

require 'test_helper'

class ProtocolsControllerTest < ActionDispatch::IntegrationTest
  test 'new renders the mobile form with the request as message number' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    get '/requests/53/protocols/new', params: { mobile: 'true' }, xhr: true

    assert_response :success
    assert_includes response.body, "KS.nav.switchTo('protocol'"
    assert_includes response_text, 'value="53"'
  end

  test 'new is forbidden without js' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    get '/requests/53/protocols/new'

    assert_response :forbidden
  end

  test 'create mails the protocol' do
    assert_emails 1 do
      post '/requests/53/protocols', xhr: true, params: {
        mobile: 'true', protocol: { user: 'Max', process_number: '42', message_number: '53', text: 'Erledigt' }
      }
    end
    assert_includes ActionMailer::Base.deliveries.last.body.to_s, 'Erledigt'
  end

  test 'create keeps the id list of the form for the redirect' do
    post '/requests/53/protocols', xhr: true,
      params: { mobile: 'true', protocol: { user: 'Max', text: 'Erledigt', id_list: %w[53 60] } }

    assert_includes response.body, "', '/requests/53?id_list%5B%5D=53&id_list%5B%5D=60&mobile=true');"
  end

  test 'create shows the success with redirect on mobile' do
    post '/requests/53/protocols', xhr: true, params: { mobile: 'true', protocol: { user: 'Max', text: 'Erledigt' } }

    assert_includes response_text, I18n.t('protocols.create.success_text')
    assert_includes response.body, "', '/requests/53?mobile=true');"
  end
end
