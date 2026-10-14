# frozen_string_literal: true

require 'test_helper'

class ActiveResourceCitySDKStructurePatchTest < ActiveSupport::TestCase
  class Dummy
    prepend ActiveresourceCitysdkStructurePatch::LoadWithCitySDKArrayStructure

    # The patch always passes all arguments on to super, so no defaults are needed here.
    def load(attributes, remove_root, persisted)
      { attributes: attributes, remove_root: remove_root, persisted: persisted }
    end
  end

  test 'load converts nil attributes to an empty hash' do
    result = Dummy.new.load(nil)

    assert_equal({}, result[:attributes])
    assert_not result[:remove_root]
    assert_not result[:persisted]
  end

  test 'load uses the first entry of array payloads' do
    result = Dummy.new.load([{ id: 42 }])

    assert_equal({ id: 42 }, result[:attributes])
  end

  test 'load preserves hash payloads' do
    result = Dummy.new.load({ id: 7 }, true, true)

    assert_equal({ id: 7 }, result[:attributes])
    assert result[:remove_root]
    assert result[:persisted]
  end

  { 400 => 'Anfrage ungültig', 401 => 'API-Key ungültig', 422 => 'E-Mail ungültig' }.each do |status, message|
    test "save returns false and loads the CitySDK errors of a #{status} response" do
      mock_city_sdk :post, 'requests/comments/53', [{ code: status.to_s, description: message }], status
      comment = Comment.new(service_request_id: 53, comment: 'Lob')

      assert_not comment.save
      assert_equal [message], comment.errors.full_messages
    end
  end

  test 'forbidden errors provide a base object with the CitySDK errors' do
    mock_city_sdk :post, 'requests/notes/53', [{ code: '403', description: 'Keine Berechtigung' }], 403

    error = assert_raises(ActiveResource::ForbiddenAccess) { Note.create(service_request_id: 53, comment: 'x') }
    assert_equal ['Keine Berechtigung'], error.base_object_with_errors.errors.full_messages
  end
end
