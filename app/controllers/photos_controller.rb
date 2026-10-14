# frozen_string_literal: true

class PhotosController < ApplicationController
  include RequestFeedback

  # Foto melden
  # params:
  #   service_request_id  pflicht  - Vorgang-ID
  #   author              pflicht  - Autor-Email
  #   media               pflicht  - Bild
  def create
    photo = Photo.create(photo_params.merge(service_request_id: params[:request_id]))
    @redirect = request_redirect_path
    render_create_result photo
  end

  private

  def photo_params
    params.expect(photo: %i[author media]).tap do |data|
      data[:media] = Base64.encode64(data[:media].read) if data[:media].present?
    end
  end
end
