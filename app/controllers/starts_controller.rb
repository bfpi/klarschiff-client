class StartsController < ApplicationController
  def show
    @request_id = params[:request]
    return redirect_to "#{ Settings::Url.ks_server_url }#{ map_path(request: @request_id, mobile: true) }" if login_required?
    return redirect_to "#{ Settings::Url.ks_server_url }#{ map_path }" if Settings::Client.skip_extra_homepage
    recent_requests
    @current_count = Request.count(also_archived: false, detailed_status: states, keyword: 'problem, idea')
    @overall_count = Request.count(also_archived: true, detailed_status: states, keyword: 'problem, idea')
    @newest_count = Request.count(also_archived: true, detailed_status: states, keyword: 'problem, idea',
                                  start_date: Date.today - 30)
    @processed_count = Request.count(also_archived: true, detailed_status: 'PROCESSED', keyword: 'problem, idea',
                                     start_date: Date.today - 30)
  end

  def recent_requests
    @recent_requests = Request.where(max_requests: Settings::Client.recent_requests, detailed_status: states, keyword: 'problem, idea',
                              with_picture: true)
    @recent_requests_col = "col-#{ 12/Settings::Client.recent_requests_per_row.to_i }"
  end

  private
  def states
   Settings::Map.default_requests_states.strip.split(', ').select { |s| s != 'PENDING' }.join(', ')
  end
end
