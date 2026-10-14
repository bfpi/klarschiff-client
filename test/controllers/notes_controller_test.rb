# frozen_string_literal: true

require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  def post_note(status: 201, description: nil)
    body = description ? [{ code: status.to_s, description: description }] : [{ service_request_id: 53 }]
    mock_city_sdk :post, 'requests/notes/53', body, status
    post '/requests/53/notes', xhr: true,
      params: { mobile: 'true', author: 'a@b.de', note: { comment: 'Notiz', id_list: %w[1 2] } }
  end

  test 'new renders the mobile form' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    get '/requests/53/notes/new', params: { mobile: 'true' }, xhr: true

    assert_response :success
    assert_includes response.body, "KS.nav.switchTo('note'"
  end

  test 'create posts the note with author and api key' do
    post_note

    assert_equal({ 'comment' => 'Notiz', 'author' => 'a@b.de', 'api_key' => Note.api_key,
                   'privacy_policy_accepted' => false }, city_sdk_body(:post, 'requests/notes/53'))
  end

  test 'create shows the success with redirect' do
    post_note

    assert_includes response_text, I18n.t('notes.create.success_text')
    assert_includes response.body, "', '/requests/53?id_list%5B%5D=1&id_list%5B%5D=2&mobile=true');"
  end

  test 'create shows validation errors without redirect' do
    post_note status: 422, description: 'Text fehlt'

    assert_includes response_text, '<p>Text fehlt</p>'
    assert_not_includes response.body, '/requests/53?'
  end

  test 'create shows forbidden errors without redirect' do
    post_note status: 403, description: 'Keine Berechtigung'

    assert_includes response_text, '<p>Keine Berechtigung</p>'
    assert_not_includes response.body, '/requests/53?'
  end
end
