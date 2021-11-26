# frozen_string_literal: true

class Area < ActiveResource::Base
  include ResourceClient

  set_server_connection :city_sdk

  attr_accessor :id, :name, :grenze
end
