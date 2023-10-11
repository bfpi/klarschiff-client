class Place
  include ActiveModel::Model

  attr_accessor :type, :properties, :geometry

  def as_json(options = {})
    { label: label(properties), bbox: bbox(geometry), transform_bbox: geometry['transform_bbox'], feature_id: properties['feature_id'] }
  end

  private
  
  def label(properties)
    title = properties['_title_']
    title_without_community = title.split(', ')[-1]
    case properties['objektgruppe']
    when 'Gemeinde'
      title
    when 'Gemeindeteil'
      title_without_community
    else
      properties['abkuerzung'].blank? ? title_without_community : title_without_community + ' (' + properties['abkuerzung'] + ')'
    end
  end

  def bbox(geometry)
    geometry['type'] == 'Point' ? [geometry['coordinates'][0],geometry['coordinates'][1],geometry['coordinates'][0],geometry['coordinates'][1]] : [geometry['coordinates'][0][0][0],geometry['coordinates'][0][0][1],geometry['coordinates'][0][2][0],geometry['coordinates'][0][2][1]]
  end
end
