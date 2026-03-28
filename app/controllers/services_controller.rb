class ServicesController < ApplicationController
  clear_respond_to
  respond_to :json

  def index
    respond_with Service.where(params.permit(:lat, :long).merge(group: params[:category], keywords: params[:type]))
  rescue ActionController::UnknownFormat
    head :not_acceptable
  end
end
