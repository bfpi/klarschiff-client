class User
  include ActiveModel::Model

  attr_accessor :name, :email, :field_service_team

  def field_service_team # TODO: aus LDAP lesen
    'A-Team'
  end
end
