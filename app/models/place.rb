class Place
  include ActiveModel::Model

  attr_accessor :label, :bbox

  def as_json(options = {})
    { id: bbox, label: label }
  end
end
