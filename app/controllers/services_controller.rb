# frozen_string_literal: true

class ServicesController < ApplicationController
  clear_respond_to
  respond_to :json

  def index
    services = Service.collection.to_a.dup
    if (type = params[:type]).present?
      services.select! { |s| s.type == type }
    end
    if (category = params[:category]).present?
      services.select! { |s| s.group == category }
    end
    respond_with services
  rescue ActionController::UnknownFormat
    head :not_acceptable
  end
end
