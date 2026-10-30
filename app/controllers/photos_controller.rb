# frozen_string_literal: true

class PhotosController < ApplicationController
  # Foto melden
  # params:
  #   service_request_id  pflicht  - Vorgang-ID
  #   author              pflicht  - Autor-Email
  #   media               pflicht  - Bild(er), bei mehreren Bildern media[]
  def create
    if too_many_media?(params[:photo][:media])
      @errors = too_many_media_errors(Photo)
    else
      photo = Photo.create(permissable_params.merge(                  service_request_id: params[:request_id]))
      @errors = photo.errors unless photo.persisted?
    end
    @redirect = request_path(params[:request_id], id_list: params[:photo][:id_list], mobile: @mobile).html_safe
    if context == 'desktop' && @errors.present?
      @errors = Array.wrap(@errors).map(&:messages)
      return render 'application/desktop/new'
    end
    render "/application/#{context}/create"
  end

  private

  def permissable_params
    keys = %i[author media]
    data = params.require(:photo).permit(keys)
    if (files = media_files(params[:photo][:media])).present?
      data[:media] = media_payload(files.map { |file| Base64.encode64(file.read) })
    end
    data
  end
end
