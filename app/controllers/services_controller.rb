# frozen_string_literal: true

class ServicesController < ApplicationController
  clear_respond_to
  respond_to :json

  def index
    respond_with Service.where(permitted_params.slice(:lat, :long).merge(group: permitted_params[:category],
                                                                         keywords: permitted_params[:type]))
  rescue ActionController::UnknownFormat
    head :not_acceptable
  end

  private

  def permitted_params
    params.permit(:lat, :long, :category, :type)
  end
end
