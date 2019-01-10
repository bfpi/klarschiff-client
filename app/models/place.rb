class Place
  include ActiveModel::Model

  attr_accessor :type, :properties, :geometry

  def as_json(options = {})
    { label: properties['objektgruppe'] == 'Gemeindeteil' ? properties['_title_'].split(', ')[-1] : properties['abkuerzung'].blank? ? properties['_title_'].split(', ')[-1] : properties['_title_'].split(', ')[-1] + ' (' + properties['abkuerzung'] + ')', bbox: geometry['type'] == 'Point' ? [geometry['coordinates'][0],geometry['coordinates'][1],geometry['coordinates'][0],geometry['coordinates'][1]] : [geometry['coordinates'][0][0][0],geometry['coordinates'][0][0][1],geometry['coordinates'][0][2][0],geometry['coordinates'][0][2][1]], transform_bbox: geometry['transform_bbox'], feature_id: properties['feature_id'] }
  end
end
