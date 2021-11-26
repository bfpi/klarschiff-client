# frozen_string_literal: true

class User < ActiveResource::Base
  include ResourceClient
  set_server_connection :city_sdk
end
