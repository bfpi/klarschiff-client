# frozen_string_literal: true

require 'test_helper'

class ActiveResourceCitySDKStructurePatchTest < ActiveSupport::TestCase
  class Dummy
    prepend ActiveresourceCitysdkStructurePatch::LoadWithCitySDKArrayStructure

    def load(attributes, remove_root = false, persisted = false)
      { attributes: attributes, remove_root: remove_root, persisted: persisted }
    end
  end

  class DummyResource < ActiveResource::Base
    self.site = 'https://klarschiff.de/citysdk/'
    self.format = :json
  end

  RESOURCE_PATH = '/citysdk/dummy_resources.json'
  ERROR_HEADERS = { 'Content-Type' => 'application/json' }.freeze

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

  test 'save returns false and exposes CitySDK errors on 400 Bad Request' do
    resource = save_with_backend_response(400, 'Beschreibung fehlt')

    assert_not_predicate resource, :persisted?
    assert_includes resource.errors.full_messages, 'Beschreibung fehlt'
  end

  test 'save returns false and marks resource invalid on 401 Unauthorized' do
    resource = save_with_backend_response(401, 'Benutzername oder Passwort falsch')

    assert_not_predicate resource, :valid?
    assert_includes resource.errors.full_messages, 'Benutzername oder Passwort falsch'
  end

  private

  def save_with_backend_response(status, description)
    ActiveResource::HttpMock.respond_to(false) do |mock|
      mock.post RESOURCE_PATH, ERROR_HEADERS, [{ code: status, description: description }].to_json, status
    end

    DummyResource.new(name: 'test').tap do |resource|
      assert_not resource.save
    end
  end
end
