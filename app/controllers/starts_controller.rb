class StartsController < ApplicationController
  def show
    @request_id = params[:request]
    return redirect_to "#{ Settings::Url.ks_server_url }#{ map_path(request: @request_id, mobile: true) }" if login_required?
    return redirect_to "#{ Settings::Url.ks_server_url }#{ map_path }" if Settings::Client.skip_extra_homepage
    states = Settings::Map.default_requests_states.strip.split(', ').select { |s| s != 'PENDING' }.join(', ')
    @requests = Request.where(max_requests: 6, detailed_status: states, keyword: 'problem, idea',
                              with_picture: true)
    @current_count = Request.count(also_archived: false, detailed_status: states, keyword: 'problem, idea')
    @overall_count = Request.count(also_archived: true, detailed_status: states, keyword: 'problem, idea')
    @newest_count = Request.count(also_archived: true, detailed_status: states, keyword: 'problem, idea',
                                  start_date: Date.today - 30)
    @processed_count = Request.count(also_archived: true, detailed_status: 'PROCESSED', keyword: 'problem, idea',
                                     start_date: Date.today - 30)
  end
end
