# frozen_string_literal: true

require 'test_helper'

class SettingsTest < ActiveSupport::TestCase
  test 'client returns false for missing show settings' do
    assert_not Settings::Client.show_something_unknown
    assert_respond_to Settings::Client, :show_something_unknown
  end

  test 'client raises for other missing settings' do
    assert_raises(NoMethodError) { Settings::Client.something_unknown }
    assert_not_respond_to Settings::Client, :something_unknown
  end

  test 'route resolves paths' do
    assert_equal '/requests/53', Settings::Route.request_path(53)
    assert_respond_to Settings::Route, :request_path
  end

  test 'route prefixes paths with the relative url root' do
    Settings::Route.stub(:relative_url_root, '/client') do
      assert_equal '/client/requests/53', Settings::Route.request_path(53)
    end
  end

  test 'route resolves asset paths' do
    assert_match %r{\A/assets/rss(-\h+)?\.png\z}, Settings::Route.path_to_image('rss.png')
    assert_respond_to Settings::Route, :path_to_image
  end

  test 'route raises for other missing methods' do
    assert_raises(NoMethodError) { Settings::Route.something_unknown }
    assert_not_respond_to Settings::Route, :something_unknown
  end
end
