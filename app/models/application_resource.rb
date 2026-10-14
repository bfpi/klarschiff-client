# frozen_string_literal: true

class ApplicationResource < ActiveResource::Base
  include ResourceClient

  connects_to :city_sdk
end
