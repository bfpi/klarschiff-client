class Request < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  default_query_options[:extensions] = true

  belongs_to :service, foreign_key: 'service_code'

  alias_attribute :id, :service_request_id

  # Workaround, to overcome the missing foreign_key option when defining has_many
  def comments
    @comments ||= Comment.where(service_request_id: id)
  end

  # Workaround, to overcome the missing foreign_key option when defining has_many
  def notes
    @notes ||= Note.where(service_request_id: id)
  end

  def icon_list
    "icons/list/" << icon << "-22px.png"
  end

  def icon_map
    "icons/map/inactive/" << icon << ".png"
  end

  def icon
    "png/#{ service.type }-" << case extended_attributes.detailed_status
    when 'IN_PROCESS'
      "yellow"
    when 'PENDING'
      "gray"
    when 'PROCESSED'
      "green"
    when 'RECEIVED'
      "red"
    when 'REJECTED'
      "yellowgreen"
    end
  end

  def as_json(options = {})
    serializable_hash options.merge(methods: :icon_map)
  end

  class ExtendedAttributes < Request
    # Overwrite Object#trust
    def trust
      attributes[:trust]
    end

    def as_json(options = {})
      serializable_hash options.merge(methods: nil)
    end
  end
end
