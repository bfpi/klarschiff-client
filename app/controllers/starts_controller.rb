class StartsController < ApplicationController
  include ApplicationHelper

  def show
    @request_id = params[:request]
    return redirect_to "#{ Settings::Url.ks_server_url }#{ map_path(request: @request_id, mobile: true) }" if login_required?
    return redirect_to "#{ Settings::Url.ks_server_url }#{ map_path }" if Settings::Client.skip_extra_homepage
    recent_requests
  end

  def recent_requests
    @recent_requests = Request.where(max_requests: Settings::Client.recent_requests, detailed_status: states, keyword: 'problem, idea',
                              with_picture: true)
    @recent_requests_col = "col-#{ 12/Settings::Client.recent_requests_per_row.to_i }"
  end

end
