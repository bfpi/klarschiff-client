# frozen_string_literal: true

class Comment < ActiveResource::Base
  include ResourceClient
  set_server_connection :city_sdk
  self.prefix = File.join(site.path, '/requests/comments/:service_request_id')
end
