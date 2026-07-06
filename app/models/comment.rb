# frozen_string_literal: true

class Comment < ApplicationResource
  self.prefix = File.join(site.path, '/requests/comments/:service_request_id')
end
