class VotesController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @vote = Vote.new(
      service_request_id: @request.id, author: login_required? ? @user.email : nil,
      privacy_policy_accepted: nil, status_updates_for_supporter: nil
    )
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{ context }/new" }
    end
  end

  def create
    vote = Vote.create(
      params.require(:vote).permit(:author).merge(
        service_request_id: params[:request_id], privacy_policy_accepted: params[:vote][:privacy_policy_accepted].present?,
        status_updates_for_supporter: params[:vote][:status_updates_for_supporter].present?
      )
    )
    @redirect = request_path(params[:request_id], id_list: params[:vote][:id_list], mobile: @mobile).html_safe
    @errors = vote.errors unless vote.persisted?
    if context == 'desktop' && @errors.present?
      @errors = Array.wrap(@errors).map(&:messages)
      return render 'application/desktop/new'
    end
    render "/application/#{ context }/create"
  end
end
