# frozen_string_literal: true

require 'test_helper'

class ActiveResourceCitySDKStructurePatchTest < ActiveSupport::TestCase
  class Dummy
    prepend ActiveResource::LoadWithCitySDKArrayStructure

    def load(attributes, remove_root = false, persisted = false)
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
end
