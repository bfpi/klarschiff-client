module ObservationsHelper
  def service_names(type)
    Service.where(extended: true).select { |s| s.group == nil && s.type == type }.map { |s| { id: s.service_code, name: s.service_name } }
  end
end
