class Vote < ActiveResource::Base
  include ResourceClient
  self.set_server_connection :city_sdk
  self.prefix = "/requests/votes/:service_request_id"

  # TODO: in einer generischen Form in den Initializer-Patch auslagern°
  def self.collection_path(prefix_options = {}, query_options = nil)
    check_prefix_options(prefix_options)
    prefix_options, query_options = split_options(prefix_options) if query_options.nil?
    "#{ prefix(prefix_options) }#{ format_extension }#{ query_string(query_options) }"
  end
end
