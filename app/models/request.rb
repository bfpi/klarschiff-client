class Request < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  default_query_options[:extensions] = true

  alias_attribute :id, :service_request_id

  delegate :detailed_status, :detailed_status=, :job_status, :description_public,
    :votes,
    to: :extended_attributes

  # Workaround, to overcome the missing foreign_key option when defining has_many
  %i(comments notes).each do |func|
    define_method(func) {
      begin 
        func.to_s.classify.constantize.where(service_request_id: id)
      rescue
        nil
      end
    }
  end

  def service
    @service ||= Service[service_code]
  end

  def title
    description.try(:split, /: ?/).try(:first).try :truncate, 60, separator: ' '
  end

  def lat
    attributes[:lat] ||= attributes[:position].try(:last).presence
  end

  def long
    attributes[:long] ||= attributes[:position].try(:first).presence
  end

  def icon_list
    Settings::Route.path_to_image "icons/list/#{ icon }-22px.png"
  end

  def icon_map
    Settings::Route.path_to_image "icons/map/#{ icon_folder }/#{ icon }.png"
  end

  def icon_active_map
    Settings::Route.path_to_image "icons/map/active/#{ icon }.png"
  end

  def min_req
    @min_req ||= Settings::Vote.min_requirement || 0
  end

  def idea?
    service.type.idea?
  end

  def problem?
    service.type.problem?
  end

  def tipp?
    service.type.tipp?
  end

  def under_req?
    votes < min_req
  end

  def media_required?
    !media_url.present? || extended_attributes.photo_required
  end

  def flag_color_class
    "job-status " << case job_status
      when 'NOT_CHECKABLE'
        "not-checkable"
      when 'CHECKED'
        "checked"
      else
        "unchecked"
    end
  end

  def as_json(options = {})
    serializable_hash options.merge(methods: :icon_map)
  end

  private
  def icon
    "png/#{ attributes[:type] || service.type }-#{ icon_color }" if service
  end

  def icon_color
    case detailed_status
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
  rescue
    "gray"
  end

  def icon_folder
    if expected_datetime.try(:to_date) == Date.today && Settings::Client.login_required
      "task-#{ extended_attributes.respond_to?(:job_status) ? job_status.downcase.dasherize : 'unchecked' }"
    else
      "inactive"
    end
  end

  def method_missing(name, *args, &block)
    if name =~ /=$/
      super
    else
      attributes[name].presence
    end
  end

  def self.count(params)
    return self.where(params.merge({ :just_count => true })).first.count
  end

  class ExtendedAttributes < ActiveResource::Base
    include ResourceClient
    self.set_server_connection :city_sdk

    # Overwrite Object#trust, #job_status
    %i(trust job_status).each do |tmp|
      define_method(tmp){attributes[tmp]}
    end
  end
end
