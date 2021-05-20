module ObservationsHelper
  def service_names(type)
    Service.where(extended: true).select { |s| s.type == type }.map { |s| { id: s.group_id, name: s.group } }.uniq
  end

  def service_name(code)
    Service.find(code)
  end
end
