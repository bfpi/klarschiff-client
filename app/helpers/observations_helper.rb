module ObservationsHelper
  def service_names(type) 
    Service.where(extended: true).select { |s| s.group == nil && s.type == type }.map { |s| { id: s.service_code, name: s.service_name } }
  end

  def service_name(code)
    Service.where(extended: true).find { |s| s.group == nil && s.service_name == Service.find(code).group }
  end
end
