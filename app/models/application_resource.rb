# frozen_string_literal: true

class ApplicationResource < ActiveResource::Base
  include ResourceClient
  set_server_connection :city_sdk
end
