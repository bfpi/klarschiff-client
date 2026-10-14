# frozen_string_literal: true

require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  POLYGON = { 'type' => 'Polygon', 'coordinates' => [[[12.1, 54.1], [12.2, 54.1], [12.2, 54.2], [12.1, 54.2]]] }.freeze

  def place(properties, geometry = POLYGON)
    Place.new(type: 'Feature', properties: properties, geometry: geometry).as_json
  end

  test 'as_json uses the corners of a polygon as bbox' do
    assert_equal [12.1, 54.1, 12.2, 54.2], place('_title_' => 'Rostock')[:bbox]
  end

  test 'as_json uses a point as bbox' do
    json = place({ '_title_' => 'Meldung #53', 'feature_id' => 53 },
      { 'type' => 'Point', 'coordinates' => [12.1, 54.1], 'transform_bbox' => true })

    assert_equal({ label: 'Meldung #53', bbox: [12.1, 54.1, 12.1, 54.1], transform_bbox: true, feature_id: 53 }, json)
  end

  test 'as_json labels a community with its full title' do
    assert_equal 'Landkreis, Rostock', place('_title_' => 'Landkreis, Rostock', 'objektgruppe' => 'Gemeinde')[:label]
  end

  test 'as_json labels a community part without the community' do
    assert_equal 'Mitte', place('_title_' => 'Rostock, Mitte', 'objektgruppe' => 'Gemeindeteil')[:label]
  end

  test 'as_json labels other places with their abbreviation' do
    assert_equal 'Hauptstraße (HRO)',
      place('_title_' => 'Rostock, Hauptstraße', 'objektgruppe' => 'Straße', 'abkuerzung' => 'HRO')[:label]
  end

  test 'as_json labels other places without abbreviation' do
    assert_equal 'Hauptstraße', place('_title_' => 'Rostock, Hauptstraße', 'objektgruppe' => 'Straße')[:label]
  end
end
