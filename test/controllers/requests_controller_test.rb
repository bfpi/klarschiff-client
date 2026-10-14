# frozen_string_literal: true

require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  STATES = 'PENDING, RECEIVED, IN_PROCESS, PROCESSED, REJECTED'
  OUTSIDE = 'Position befindet sich außerhalb des gültigen Bereichs'
  COORDINATE = Struct.new(:redirect_url, :covered) do
    def covered_by_juristiction? = covered
  end

  def mock_requests(*requests)
    mock_city_sdk :get, 'requests', requests.presence || [request_payload(53), request_payload(60)]
  end

  def index_query(**params)
    mock_requests
    get '/requests.json', params: params
    city_sdk_query(:get, 'requests')
  end

  def default_query(**query)
    { 'api_key' => Request.api_key, 'detailed_status' => STATES, 'extensions' => 'true', 'radius' => nil }
      .merge(query.stringify_keys)
  end

  def with_coordinate(redirect_url: nil, covered: true, &)
    Coordinate.stub(:new, COORDINATE.new(redirect_url, covered), &)
  end

  def with_also_archived
    Settings::Client.define_singleton_method(:also_archived) { true }
    yield
  ensure
    Settings::Client.singleton_class.send(:remove_method, :also_archived)
  end

  # index

  test 'index requests all default states' do
    assert_equal default_query, index_query
  end

  test 'index requests with the desktop filters' do
    query = index_query(area: '13', map: 'bbox', service_code: '4', ids: %w[53 60], start_date: '2024-01-02',
      center: %w[54.1 12.1], typ: ['problem', '', 'idea'], status: ['RECEIVED', ''], radius: '50')

    assert_equal default_query(area_code: '13', map: 'bbox', service_code: '4', service_request_id: '53,60',
      start_date: '2024-01-02T00:00:00Z', lat: '54.1', long: '12.1',
      keyword: 'problem, idea', detailed_status: 'RECEIVED', radius: '50'), query
  end

  test 'index requests no state if all states are deselected' do
    assert_equal default_query(detailed_status: '', status: ''), index_query(status: [''])
  end

  test 'index ignores type and state filters on mobile' do
    assert_equal default_query(mobile: nil).except('mobile'),
      index_query(mobile: 'true', typ: ['problem'], status: ['RECEIVED'])
  end

  test 'index requests archived requests if enabled' do
    with_also_archived do
      assert_equal default_query(also_archived: 'true'), index_query(archive: '1')
    end
  end

  test 'index returns the requests as json' do
    mock_requests
    get '/requests.json'

    assert_equal [53, 60], response.parsed_body.pluck('service_request_id')
  end

  test 'index renders the mobile list' do
    mock_requests
    get '/requests', params: { mobile: 'true' }, xhr: true

    assert_includes response.body, "KS.nav.switchTo('requests'"
    assert_includes response_text, '/requests/60?id_list%5B%5D=53&id_list%5B%5D=60&mobile=true'
  end

  test 'index renders the desktop start without requesting the backoffice on back' do
    get '/requests', params: { back: 'true' }, xhr: true

    assert_includes response_text, I18n.t('buttons.new_request')
    assert_empty city_sdk_requests(:get, 'requests')
  end

  test 'index redirects to the first request on desktop' do
    host! 'localhost:3000' # the redirect leads to Settings::Url.ks_server_url
    mock_requests
    get '/requests', params: { refresh: 'true' }, xhr: true

    assert_redirected_to 'http://localhost:3000/requests/53?id_list%5B%5D=53&id_list%5B%5D=60&mobile=false&refresh=true'
  end

  test 'index writes the static request pages' do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, '9.html'), 'alt')
      mock_requests request_payload(53, description: 'Ältere Meldung', requested_datetime: '2021-07-26T08:20:45+02:00'),
        request_payload(60, description: 'Neuere Meldung', requested_datetime: '2021-08-26T08:20:45+02:00')
      Settings::Client.stub(:resources_overview_path, dir) { get '/requests', params: { per_page: 1 } }

      assert_response :success
      assert_equal %w[1.html 2.html], Dir.children(dir).sort
      assert_includes File.read(File.join(dir, '1.html')), 'Neuere Meldung'
    end
  end

  # show

  test 'show renders the request on desktop' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    get '/requests/53', params: { id_list: %w[53 60] }, xhr: true

    assert_response :success
    assert_includes response_text, 'Loch in der Straße'
    assert_not_includes response.body, 'setZoom'
  end

  test 'show renders the request on mobile' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    get '/requests/53', params: { mobile: 'true' }, xhr: true

    assert_includes response.body, "KS.nav.switchTo('request'"
    assert_includes response_text, 'Loch in der Straße'
  end

  test 'show escapes the status notes' do
    mock_city_sdk :get, 'requests/53', [request_payload(status_notes: '<b>wichtig</b>')]
    get '/requests/53', xhr: true

    assert_includes response.body, '<em>&lt;b&gt;wichtig&lt;/b&gt;<\/em>'
  end

  test 'show renders the mobile popup' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    get '/requests/53', params: { mobile: 'true', mobile_popup: 'true' }, xhr: true

    assert_includes response.body, 'KS.popupContent.innerHTML'
  end

  test 'show searches the request with the default states if requested directly' do
    mock_requests request_payload
    get '/requests/53', params: { direct: 'true' }, xhr: true

    assert_includes response.body, 'setZoom'
    assert_equal({ 'api_key' => Request.api_key, 'detailed_status' => STATES, 'extensions' => 'true',
                   'service_request_id' => '53' }, city_sdk_query(:get, 'requests'))
  end

  test 'show returns not found if the direct request does not exist' do
    mock_city_sdk :get, 'requests', []
    get '/requests/53', params: { direct: 'true' }, xhr: true

    assert_response :not_found
  end

  # new

  test 'new is forbidden as html' do
    get '/requests/new'

    assert_response :forbidden
  end

  test 'new renders the desktop form' do
    get '/requests/new', xhr: true

    assert_includes response.body, 'KS.createFeature(type, coord)'
    assert_includes response_text, 'id="request-form"'
  end

  test 'new switches the type on desktop' do
    get '/requests/new', params: { switch_type: 'true', type: 'idea' }, xhr: true

    assert_includes response.body, 'KS.styles.newFeature("idea")'
  end

  test 'new asks for the position on mobile' do
    get '/requests/new', params: { mobile: 'true' }, xhr: true

    assert_includes response.body, "KS.createFeature('blank')"
  end

  test 'new renders the mobile form for a position inside the jurisdiction' do
    with_coordinate { get '/requests/new', params: { mobile: 'true', position: %w[12.1 54.1] }, xhr: true }

    assert_includes response.body, "KS.nav.switchTo('request'"
  end

  test 'new switches the type on mobile' do
    with_coordinate do
      get '/requests/new', params: { mobile: 'true', position: %w[12.1 54.1], switch_type: 'true', type: 'idea' },
        xhr: true
    end

    assert_includes response.body, "$('#type-select').replaceWith"
  end

  test 'new rejects a position outside the jurisdiction on mobile' do
    with_coordinate(covered: false) do
      get '/requests/new', params: { mobile: 'true', position: %w[12.1 54.1] }, xhr: true
    end

    assert_includes response_text, 'modal-header text-warning'
    assert_includes response_text, "<p>#{OUTSIDE}</p>"
  end

  test 'new redirects to the responsible instance on mobile' do
    with_coordinate(redirect_url: 'https://andere.example', covered: false) do
      get '/requests/new', params: { mobile: 'true', position: %w[12.1 54.1] }, xhr: true
    end

    assert_includes response.body, "location.href = 'https://andere.example/map?new_position=12.1,54.1'"
  end

  test 'new checks a position as json' do
    with_coordinate { get '/requests/new.json', params: { position: %w[12.1 54.1] } }

    assert_equal({ 'status' => 200 }, response.parsed_body)
  end

  test 'new rejects a position outside the jurisdiction as json' do
    with_coordinate(covered: false) { get '/requests/new.json', params: { position: %w[12.1 54.1] } }

    assert_equal({ 'status' => 406, 'error' => OUTSIDE }, response.parsed_body)
  end

  test 'new redirects to the responsible instance as json' do
    with_coordinate(redirect_url: 'https://andere.example') do
      get '/requests/new.json', params: { position: %w[12.1 54.1] }
    end

    assert_response :see_other
    assert_equal 'https://andere.example', response.headers['X-Redirect-Url']
  end

  # edit

  test 'edit renders the form' do
    mock_city_sdk :get, 'requests/53', [request_payload]
    get '/requests/53/edit', params: { mobile: 'true' }, xhr: true

    assert_includes response.body, "KS.nav.switchTo('request'"
  end

  # create

  REQUEST_FIELDS = { service_code: ['4'], description: 'Loch', email: 'a@b.de', lat: '54.1', long: '12.1' }.freeze

  def post_request(status: 201, **params)
    if status == 201
      mock_city_sdk_http :post, 'requests', Net::HTTPCreated, [request_payload(70, create_message: 'Danke!')]
    else
      mock_city_sdk :post, 'requests', [{ code: status.to_s, description: 'Beschreibung fehlt' }], status
    end
    post '/requests', params: { request: REQUEST_FIELDS }.deep_merge(params), xhr: true
  end

  test 'create posts the request to the backoffice' do
    post_request

    assert_equal({ 'api_key' => Request.api_key, 'email' => 'a@b.de' }, city_sdk_query(:post, 'requests'))
    assert_equal({ 'description' => 'Loch', 'email' => 'a@b.de', 'lat' => '54.1', 'long' => '12.1',
                   'privacy_policy_accepted' => false, 'service_code' => 4 }, city_sdk_body(:post, 'requests'))
  end

  test 'create posts one request per service code' do
    post_request request: { service_code: %w[4 5] }

    assert_equal([4, 5], city_sdk_requests(:post, 'requests').map { |req| JSON.parse(req.body)['service_code'] })
  end

  test 'create stops after the first error' do
    post_request status: 422, request: { service_code: %w[4 5] }

    assert_equal 1, city_sdk_requests(:post, 'requests').size
  end

  test 'create sends a previously uploaded image' do
    path = Rails.root.join('tmp/request_test_upload.jpg')
    File.write(path, 'JPEG')
    post_request request: { media: 'request_test_upload.jpg' }

    assert_equal Base64.encode64('JPEG'), city_sdk_body(:post, 'requests')['media']
    assert_not File.exist?(path)
  ensure
    FileUtils.rm_f(path)
  end

  test 'create sends an uploaded image' do
    post_request request: { media: Rack::Test::UploadedFile.new(StringIO.new('PNG'), 'image/png', original_filename: 'foto.png') }

    assert_equal Base64.encode64('PNG'), city_sdk_body(:post, 'requests')['media']
  end

  test 'create shows the success with permalink on desktop' do
    post_request

    assert_includes response_text, 'Danke!'
    assert_includes response_text, 'href="/map?request=70"'
  end

  test 'create shows the success with redirect on mobile' do
    post_request mobile: 'true', request: { service_code: %w[4 5] }

    assert_includes response_text, '2 Probleme wurden erfolgreich angelegt.'
    assert_includes response.body, "', '/requests?ids%5B%5D=70&ids%5B%5D=70&mobile=true&refresh=true');"
  end

  test 'create shows the errors of the backoffice on desktop' do
    post_request status: 422

    assert_includes response.body, "$('.errors').replaceWith"
    assert_includes response_text, 'Beschreibung fehlt'
  end

  test 'create shows the errors of the backoffice on mobile' do
    post_request status: 422, mobile: 'true'

    assert_includes response_text, 'modal-header text-warning'
    assert_includes response_text, '<p>Beschreibung fehlt</p>'
  end

  test 'create requires a service code on desktop' do
    post '/requests', params: { request: REQUEST_FIELDS.except(:service_code) }, xhr: true

    assert_includes response_text, 'Haupt- und Unterkategorie müssen angegeben werden'
    assert_empty city_sdk_requests(:post, 'requests')
  end

  test 'create requires a service code on mobile' do
    post '/requests', params: { mobile: 'true', request: REQUEST_FIELDS.except(:service_code) }, xhr: true

    assert_includes response_text, '<p>Kategorie muss angegeben werden</p>'
  end

  test 'create renders the summary before confirmation' do
    mock_city_sdk :get, 'services/4', service_payload
    post '/requests', params: { confirm: 'true', mobile: 'true', request: REQUEST_FIELDS }, xhr: true

    assert_includes response.body, "$('#confirm-new-request').replaceWith"
    assert_includes response_text, 'Loch'
    assert_empty city_sdk_requests(:post, 'requests')
  end

  # update

  def patch_request(status: 200)
    if status == 200
      mock_city_sdk_http :patch, 'requests/53', Net::HTTPOK, []
    else
      mock_city_sdk :patch, 'requests/53', [{ code: status.to_s, description: 'Status ungültig' }], status
    end
    patch '/requests/53', xhr: true, params: {
      mobile: 'true', request: { description: 'neu', email: 'a@b.de', detailed_status: 'PROCESSED',
                                 job_status: 'CHECKED', id_list: %w[53 60] }
    }
  end

  test 'update patches the request in the backoffice' do
    patch_request

    assert_equal({ 'api_key' => Request.api_key, 'email' => 'a@b.de' }, city_sdk_query(:patch, 'requests/53'))
    assert_equal({ 'description' => 'neu', 'email' => 'a@b.de', 'detailed_status' => 'PROCESSED',
                   'job_status' => 'CHECKED' }, city_sdk_body(:patch, 'requests/53'))
  end

  test 'update shows the success with redirect' do
    patch_request

    assert_includes response_text, I18n.t('messages.success.request_update')
    assert_includes response.body, "', '/requests/53?id_list%5B%5D=53&id_list%5B%5D=60&mobile=true');"
  end

  test 'update shows the errors of the backoffice' do
    patch_request status: 422

    assert_includes response_text, '<p>Status ungültig</p>'
    assert_not_includes response.body, '/requests/53?'
  end
end
