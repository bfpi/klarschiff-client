class PhotosController < ApplicationController

  # Foto melden
  # params:
  #   service_request_id  pflicht  - Vorgang-ID
  #   author              pflicht  - Autor-Email
  #   media               pflicht  - Bild
  def create
    photo = Photo.create(permissable_params.merge(
      service_request_id: params[:request_id]))
    @redirect = request_path(params[:request_id], id_list: params[:photo][:id_list], mobile: @mobile).html_safe
    @errors = photo.errors unless photo.persisted?
    if context == 'desktop' && @errors.present?
      @errors = Array.wrap(@errors).map(&:messages)
      return render 'application/desktop/new'
    end
    render "/application/#{ context }/create"
  end
  
  private
  def permissable_params
    keys = [:author, :media]
    data = params.require(:photo).permit(keys)
    if (img = params[:photo][:media]).present?
      data[:media] = Base64.encode64(img.read)
    end
    data
  end
end
