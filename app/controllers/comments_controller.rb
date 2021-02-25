class CommentsController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @comment = Comment.new(service_request_id: @request.id, author: login_required? ?  @user.email : nil,
                           comment: nil, privacy_policy_accepted: nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js { render "/application/#{ context }/new" }
    end
  end

  def create
    comment = Comment.create(
      params.require(:comment).permit(:author, :comment).merge(
        api_key: Comment.api_key, service_request_id: params[:request_id],
        privacy_policy_accepted: params[:comment][:privacy_policy_accepted].present?
      )
    )
    if comment.persisted?
      @redirect = request_path(params[:request_id], id_list: params[:comment][:id_list], mobile: @mobile).html_safe
      @success = I18n.t(:success_text, scope: "comments.#{ context }.create")
    else
      @errors = comment.errors
    end
    if context == 'desktop' && @errors.present?
      @errors = Array.wrap(@errors).map(&:messages)
      return render 'application/desktop/new'
    end
    render "/application/#{ context }/create"
  end
end
