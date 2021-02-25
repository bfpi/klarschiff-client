class AbusesController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @abuse = Abuse.new(service_request_id: @request.id, author: login_required? ? @user.email : nil,
                       comment: nil, privacy_policy_accepted: nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{ context }/new" }
    end
  end

  def create
    abuse = Abuse.create(params.require(:abuse).permit(:author, :comment).merge(
      service_request_id: params[:request_id], privacy_policy_accepted: params[:abuse][:privacy_policy_accepted].present?))
    @redirect = request_path(params[:request_id], id_list: params[:abuse][:id_list], mobile: @mobile).html_safe
    @errors = abuse.errors unless abuse.persisted?
    if context == 'desktop' && @errors.present?
      @errors = Array.wrap(@errors).map(&:messages)
      return render 'application/desktop/new'
    end
    render "/application/#{ context }/create"
  end
end
