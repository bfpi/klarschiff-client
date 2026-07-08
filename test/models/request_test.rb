# frozen_string_literal: true

require 'test_helper'

class RequestModelTest < ActiveSupport::TestCase
  test 'title splits at colon and is truncated to 60 chars' do
    long = 'a' * 100
    req = Request.new(description: "#{long}: rest")
    title = req.title

    assert_operator(title.length, :<=, 60, "title should be truncated to <=60, got #{title.length}")
    assert title.start_with?('a')
  end

  test 'lat and long read from position' do
    req = Request.new(position: [11.1, 22.2])

    assert_in_delta 22.2, req.lat, 0.0001
    assert_in_delta 11.1, req.long, 0.0001
  end

  test 'icon path helpers call Settings::Route.path_to_image' do
    Settings::Route.define_singleton_method(:path_to_image) { |_p| 'image://dummy' }
    req = Request.new(type: 'problem')

    req.define_singleton_method(:icon_color) { 'blue' }
    assert_match %r{image://}, req.icon_list
    assert_match %r{image://}, req.icon_map
    assert_match %r{image://}, req.icon_active_map
  ensure
    Settings::Route.singleton_class.send(:remove_method, :path_to_image) if Settings::Route.respond_to?(:path_to_image)
  end

  test 'min_req and under_req? use Settings::Vote.min_requirement' do
    Settings::Vote.stub(:min_requirement, 5) do
      req = Request.new

      req.stub(:votes, 3) do
        assert_equal 5, req.min_req
        assert_predicate(req, :under_req?)
      end
    end
  end

  test 'media_required? considers media_url and extended_attributes.photo_required' do
    req = Request.new

    req.define_singleton_method(:extended_attributes) { Struct.new(:photo_required).new(true) }
    assert_predicate(req, :media_required?)

    req = Request.new(media_url: 'http://example.com/foo.jpg')
    req.define_singleton_method(:extended_attributes) { Struct.new(:photo_required).new(false) }
    assert_not req.media_required?
  end

  test 'flag_color_class maps job_status correctly' do
    req = Request.new

    req.stub(:job_status, 'CHECKED') do
      assert_match(/job-status/, req.flag_color_class)
      assert_match(/checked/, req.flag_color_class)
    end
  end

  test 'flag_color_class not checkable maps correctly' do
    req = Request.new

    req.stub(:job_status, 'NOT_CHECKABLE') do
      assert_match(/not-checkable/, req.flag_color_class)
    end
  end

  test 'flag_color_class unknown maps to unchecked' do
    req = Request.new

    req.stub(:job_status, 'UNKNOWN') do
      assert_match(/unchecked/, req.flag_color_class)
    end
  end

  test 'as_json includes icon_map' do
    Settings::Route.define_singleton_method(:path_to_image) { |_p| 'image://dummy' }
    req = Request.new(type: 'problem')
    req.define_singleton_method(:icon_map) { 'icon-map-value' }
    h = req.as_json

    assert_kind_of(Hash, h)
    assert(h.key?(:icon_map) || h.key?('icon_map'))
  ensure
    Settings::Route.singleton_class.send(:remove_method, :path_to_image) if Settings::Route.respond_to?(:path_to_image)
  end

  test 'icon_color returns gray on error' do
    req = Request.new

    req.stub(:detailed_status, -> { raise StandardError }) do
      assert_equal 'gray', req.send(:icon_color)
    end
  end

  test 'method_missing returns attributes values' do
    req = Request.new(custom_field: 'value')

    assert_equal 'value', req.custom_field
  end

  test 'self.count delegates to where and returns first.count' do
    fake_item = Class.new do
      attr_reader :count

      def initialize(count)
        @count = count
      end
    end.new(42)

    fake = [fake_item]

    Request.stub(:where, fake) do
      assert_equal 42, Request.count(foo: 'bar')
    end
  end

  test 'extended attributes trust and job_status methods' do
    ea = Request::ExtendedAttributes.new(trust: 7, job_status: 'CHECKED')

    assert_equal 7, ea.trust
    assert_equal 'CHECKED', ea.job_status
  end
end
