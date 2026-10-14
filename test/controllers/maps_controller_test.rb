# frozen_string_literal: true

require 'test_helper'

class MapsControllerTest < ActionDispatch::IntegrationTest
  test 'show hides the other features for jobs on mobile' do
    get '/map', params: { type: 'jobs', mobile: 'true' }, xhr: true

    assert_includes response.body, 'KS.layers.findById("features").setVisible(false)'
  end

  test 'show displays all features by default on mobile' do
    get '/map', params: { mobile: 'true' }, xhr: true

    assert_includes response.body, 'KS.layers.findById("features").setVisible(true)'
  end

  test 'show removes uploaded images older than a day' do
    old_image = Rails.root.join('tmp/maps_test_old.png')
    new_image = Rails.root.join('tmp/maps_test_new.jpg')
    FileUtils.touch(new_image)
    FileUtils.touch(old_image, mtime: 25.hours.ago.to_time)
    get '/map', xhr: true

    assert_not File.exist?(old_image)
    assert_path_exists new_image
  ensure
    FileUtils.rm_f([old_image, new_image])
  end
end
