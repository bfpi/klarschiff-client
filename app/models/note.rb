# frozen_string_literal: true

class Note < ApplicationResource
  self.prefix = File.join(site.path, '/requests/notes/:service_request_id')
end
