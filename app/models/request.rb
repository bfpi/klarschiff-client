class Request < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  default_query_options[:extensions] = true

  alias_attribute :id, :service_request_id

  delegate :detailed_status, :detailed_status=, :job_status, to: :extended_attributes

  # Workaround, to overcome the missing foreign_key option when defining has_many
  def comments
    @comments ||= Comment.where(service_request_id: id)
  end

  # Workaround, to overcome the missing foreign_key option when defining has_many
  def notes
    @notes ||= Note.where(service_request_id: id)
  end

  def service
    @service ||= Service.collection.find { |s| s.service_code = service_code }
  end

  def icon_list
    "icons/list/#{ icon }-22px.png"
  end

  def icon_map
    "icons/map/#{ icon_folder }/#{ icon }.png"
  end

  def icon
    "png/#{ service.type }-" << case detailed_status
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

  private
  def icon_folder
    if expected_datetime.try(:to_date) == Date.today
      "task-#{ job_status.downcase.dasherize }"
    else
      "inactive"
    end
  end

  class ExtendedAttributes < ActiveResource::Base
    include ResourceClient
    self.set_server_connection :city_sdk

    # Overwrite Object#trust
    def trust
      attributes[:trust]
    end
  end
end
