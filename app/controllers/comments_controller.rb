class CommentsController < ApplicationController
  def new
    @request = Request.find(params[:request_id])
    @comment = Comment.new(service_request_id: @request.id, author: @user.email, comment: nil)
    @id_list = params[:id_list].try(:map, &:to_i).presence
    respond_to do |format|
      format.html { head :forbidden }
      format.js
    end
  end

  def create
    comment = Comment.create(params.require(:comment).permit(:author, :comment).merge(
      api_key: Comment.api_key, service_request_id: params[:request_id]))
    @redirect = request_path(params[:request_id], id_list: params[:comment][:id_list]).html_safe
    if comment.persisted?
      @success = I18n.t(:success_text, scope: 'comments.create')
    else
      @errors = comment.errors
    end
  end
end
