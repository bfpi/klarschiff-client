class User
  include ActiveModel::Model

  attr_accessor :id, :name, :email, :field_service_team
end
