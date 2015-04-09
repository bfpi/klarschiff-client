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

  def icon
    "icons/list/png/#{ service.type }-" << case extended_attributes.detailed_status
    when 'IN_PROCESS'
      "yellow"
    when 'PENDING'
      "gray"
    when 'PROCESSED'
      "green"
    when 'RECIEVED'
      "red"
    when 'REJECTED'
      "yellowgreen"
    end << "-22px.png"
  end

  class ExtendedAttributes < Request
    # Overwrite Object#trust
    def trust
      attributes[:trust]
    end
  end
end
