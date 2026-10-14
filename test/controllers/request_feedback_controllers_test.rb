# frozen_string_literal: true

require 'test_helper'

# Shared behaviour of the controllers for feedback on a single request (abuses, comments, completions, votes)
class RequestFeedbackControllersTest < ActionDispatch::IntegrationTest
  FEEDBACK = {
    abuse: { fields: { author: 'a@b.de', comment: 'Beleidigung' } },
    comment: { fields: { author: 'a@b.de', comment: 'Lob' } },
    completion: { fields: { author: 'a@b.de', comment: 'Erledigt' } },
    vote: { fields: { author: 'a@b.de', status_updates_for_supporter: '1' },
            body: { 'status_updates_for_supporter' => true } }
  }.freeze
  ID_LIST = %w[1 2].freeze

  def redirect_path(mobile:)
    "/requests/53?id_list%5B%5D=1&id_list%5B%5D=2&mobile=#{mobile}"
  end

  def get_new(resource, **params)
    mock_city_sdk :get, 'requests/53', [request_payload]
    get "/requests/53/#{resource.to_s.pluralize}/new", params: { id_list: ID_LIST }.merge(params), xhr: true
  end

  def post_feedback(resource, status: 201, **params)
    body = status == 201 ? [{ service_request_id: 53 }] : [{ code: status.to_s, description: 'E-Mail ungültig' }]
    mock_city_sdk :post, "requests/#{resource.to_s.pluralize}/53", body, status
    mock_city_sdk :get, 'requests/53', [request_payload]
    post "/requests/53/#{resource.to_s.pluralize}", xhr: true,
      params: { resource => FEEDBACK[resource][:fields] }.deep_merge(params)
  end

  def posted_feedback(resource)
    city_sdk_body(:post, "requests/#{resource.to_s.pluralize}/53")
  end

  def expected_feedback(resource)
    FEEDBACK[resource][:fields].stringify_keys.merge('privacy_policy_accepted' => false)
                               .merge(FEEDBACK[resource][:body] || {})
  end

  class << self
    def test_new_desktop(resource)
      test "#{resource}: new renders the desktop form" do
        get_new resource

        assert_response :success
        assert_includes response_text, %(id="new-#{resource}")
        assert_includes response_text, 'href="/requests/53?id_list%5B%5D=1&id_list%5B%5D=2"'
      end
    end

    def test_new_mobile(resource)
      test "#{resource}: new renders the mobile form" do
        get_new resource, mobile: 'true'

        assert_response :success
        assert_includes response.body, "KS.nav.switchTo('#{resource}'"
      end
    end

    def test_new_without_js(resource)
      test "#{resource}: new is forbidden without js" do
        mock_city_sdk :get, 'requests/53', [request_payload]
        get "/requests/53/#{resource.to_s.pluralize}/new"

        assert_response :forbidden
      end
    end

    def test_create_body(resource)
      test "#{resource}: create posts the feedback to the backoffice" do
        post_feedback resource

        assert_equal expected_feedback(resource), posted_feedback(resource).except('api_key')
      end
    end

    def test_create_privacy_policy(resource)
      test "#{resource}: create accepts the privacy policy" do
        post_feedback resource, resource => { privacy_policy_accepted: '1' }

        assert posted_feedback(resource)['privacy_policy_accepted']
      end
    end

    def test_create_success_desktop(resource)
      test "#{resource}: create shows the success on desktop" do
        post_feedback resource, resource => { id_list: ID_LIST }

        assert_response :success
        assert_includes response_text, 'id="create-success"'
        assert_includes response_text, %(href="#{redirect_path(mobile: false)}")
      end
    end

    def test_create_success_mobile(resource)
      test "#{resource}: create shows the success on mobile" do
        post_feedback resource, mobile: 'true', resource => { id_list: ID_LIST }

        assert_response :success
        assert_includes response.body, "KS.flash.show('"
        assert_includes response.body, "', '#{redirect_path(mobile: true)}');"
      end
    end

    def test_create_errors_desktop(resource)
      test "#{resource}: create shows the errors of the backoffice on desktop" do
        post_feedback resource, status: 422

        assert_response :success
        assert_includes response_text, '<div class="alert alert-danger" role="alert">'
        assert_includes response_text, 'E-Mail ungültig'
      end
    end

    def test_create_errors_mobile(resource)
      test "#{resource}: create shows the errors of the backoffice on mobile" do
        post_feedback resource, status: 422, mobile: 'true'

        assert_response :success
        assert_includes response_text, 'modal-header text-warning'
        assert_includes response_text, '<p>E-Mail ungültig</p>'
      end
    end
  end

  FEEDBACK.each_key do |resource|
    %i[new_desktop new_mobile new_without_js create_body create_privacy_policy create_success_desktop
       create_success_mobile create_errors_desktop create_errors_mobile].each do |kind|
      send(:"test_#{kind}", resource)
    end
  end

  ERRORS = [{ code: '422', description: 'E-Mail <b>ungültig</b>' }, { code: '422', description: 'Text fehlt' }].freeze

  test 'abuse: create lists the escaped errors on desktop' do
    mock_city_sdk :post, 'requests/abuses/53', ERRORS, 422
    mock_city_sdk :get, 'requests/53', [request_payload]
    post '/requests/53/abuses', params: { abuse: FEEDBACK[:abuse][:fields] }, xhr: true

    assert_includes response.body, '<li>E-Mail &lt;b&gt;ungültig&lt;/b&gt;<\/li>'
    assert_includes response.body, '<li>Text fehlt<\/li>'
  end

  test 'abuse: create lists the escaped errors on mobile' do
    mock_city_sdk :post, 'requests/abuses/53', ERRORS, 422
    post '/requests/53/abuses', params: { mobile: 'true', abuse: FEEDBACK[:abuse][:fields] }, xhr: true

    assert_includes response.body, '<li>E-Mail &lt;b&gt;ungültig&lt;/b&gt;<\/li>'
    assert_includes response.body, '<li>Text fehlt<\/li>'
  end

  test 'comment: create sends the api key' do
    post_feedback :comment

    assert_equal Comment.api_key, posted_feedback(:comment)['api_key']
  end

  test 'comment: create shows a success text on mobile' do
    post_feedback :comment, mobile: 'true'

    assert_includes response_text, I18n.t('comments.mobile.create.success_text')
  end

  test 'completion: create is forbidden without js' do
    post '/requests/53/completions', params: { completion: FEEDBACK[:completion][:fields] }

    assert_response :forbidden
    assert_empty city_sdk_requests(:post, 'requests/completions/53')
  end
end
