# frozen_string_literal: true

class MapsController < ApplicationController
  def show
    return if (@cancel = params[:cancel])

    remove_tmp_images
    @zoom_to_jobs = params[:type] == 'jobs'
    @show_non_job_features = !@zoom_to_jobs
    @bbox = params[:bbox] if params[:bbox].present?
  end

  private

  def remove_tmp_images
    Dir.glob('tmp/*.{jpg,jpeg,png}').each do |image|
      FileUtils.rm_f(image) if File.mtime(image) <= 1.day.ago
    rescue Errno::ENOENT
      next # already removed by a concurrent request
    end
  end
end
