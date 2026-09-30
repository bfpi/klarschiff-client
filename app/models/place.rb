# frozen_string_literal: true

class Place
  include ActiveModel::Model

  attr_accessor :type, :id, :bbox, :properties, :geometry

  def label
    primary_type = properties['primaryType']
    place_description = properties['placeDescription']
    localisator = Settings::AddressSearch.localisator

    if localisator && !localisator.empty?
      title = place_description.sub(/ \(.*$/, '')
      if ['Adresse', 'Straße'].include?(primary_type)
        title += " (#{place_description.sub(/^.* OT /, '')}"
      else
        title = place_description.sub(/^.* Bereich /, '')
      end
      title
    else
      place_description
    end
  end

  def transform_bbox?
    geometry['transform_bbox']
  end

  def as_json(_options = {})
    {
      label: label,
      bbox: bbox,
      transform_bbox: transform_bbox?,
      feature_id: properties['feature_id']
    }
  end
end
