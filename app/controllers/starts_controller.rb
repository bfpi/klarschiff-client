# frozen_string_literal: true

class StartsController < ApplicationController
  def show
    @request_id = params[:request]
    return redirect_to map_url(request: @request_id, mobile: true) if login_required?
    return redirect_to map_url unless @mobile
    recent_requests
  end

  def recent_requests
    @recent_requests = Request.where(max_requests: Settings::Client.recent_requests,
                                     detailed_status: ApplicationController.helpers.states,
                                     keyword: 'problem, idea', with_picture: true)
    @recent_requests_col = "col-#{12 / Settings::Client.recent_requests_per_row.to_i}"
  end
end
