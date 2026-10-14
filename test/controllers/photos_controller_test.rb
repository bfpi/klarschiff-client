# frozen_string_literal: true

require 'test_helper'

class PhotosControllerTest < ActionDispatch::IntegrationTest
  def post_photo(status: 201, **params)
    body = status == 201 ? [{ service_request_id: 53 }] : [{ code: status.to_s, description: 'Foto zu groß' }]
    mock_city_sdk :post, 'requests/photos/53', body, status
    image = Rack::Test::UploadedFile.new(StringIO.new('JPEG'), 'image/jpeg', original_filename: 'foto.jpg')
    post '/requests/53/photos', xhr: true,
      params: { photo: { author: 'a@b.de', media: image, id_list: %w[1 2] } }.deep_merge(params)
  end

  test 'create posts the photo base64 encoded' do
    post_photo

    assert_equal({ 'author' => 'a@b.de', 'media' => Base64.encode64('JPEG') },
      city_sdk_body(:post, 'requests/photos/53'))
  end

  test 'create shows the success on desktop' do
    post_photo

    assert_includes response_text, 'id="create-success"'
    assert_includes response_text, 'href="/requests/53?id_list%5B%5D=1&id_list%5B%5D=2&mobile=false"'
  end

  test 'create shows the success on mobile' do
    post_photo mobile: 'true'

    assert_includes response.body, "', '/requests/53?id_list%5B%5D=1&id_list%5B%5D=2&mobile=true');"
  end

  test 'create shows the errors on desktop' do
    post_photo status: 422

    assert_includes response_text, '<div class="alert alert-danger" role="alert">'
    assert_includes response_text, 'Foto zu groß'
  end
end
