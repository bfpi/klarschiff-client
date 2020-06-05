class MapsController < ApplicationController
  def show
    return if @cancel = params[:cancel]
    remove_tmp_images
    @show_non_job_features = !params[:type].eql?("jobs")
    @zoom_to_jobs = params[:type].eql?("jobs")
    @bbox = params[:bbox] if params[:bbox].present?
  end

  private

  def remove_tmp_images
    images = (Dir.glob('tmp/*.jpg') + Dir.glob('tmp/*.jpeg') + Dir.glob('tmp/*.png')).compact
      .select { |image_name| (Time.current - File.mtime(image_name)) / 3600 / 24 >= 1 }
    FileUtils.rm images if images.any?
  end
end
