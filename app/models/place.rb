# frozen_string_literal: true

class Place
  include ActiveModel::Model

  attr_accessor :type, :properties, :geometry

  def as_json(_options = {})
    { label: label(properties), bbox: bbox(geometry), transform_bbox: geometry['transform_bbox'],
      feature_id: properties['feature_id'] }
  end

  private

  def label(properties)
    title = properties['_title_']
    case properties['objektgruppe']
    when 'Gemeinde' then title
    when 'Gemeindeteil' then title.split(', ').last
    else label_with_abbreviation(title.split(', ').last, properties['abkuerzung'])
    end
  end

  def label_with_abbreviation(title, abbreviation)
    abbreviation.blank? ? title : "#{title} (#{abbreviation})"
  end

  # A point is its own bbox, a polygon is spanned by its first and third corner
  def bbox(geometry)
    coordinates = geometry['coordinates']
    return coordinates.first(2) * 2 if geometry['type'] == 'Point'

    [*coordinates[0][0].first(2), *coordinates[0][2].first(2)]
  end
end
