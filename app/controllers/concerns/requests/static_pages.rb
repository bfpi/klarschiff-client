# frozen_string_literal: true

module Requests
  # Renders the list of requests into static pages, which are delivered by StaticsController#requests
  module StaticPages
    extend ActiveSupport::Concern

    private

    def write_static_pages
      requests = @requests.sort_by(&:requested_datetime).reverse
      @pages = (requests.count / static_page_size.to_f).ceil
      path = clear_static_pages
      requests.each_slice(static_page_size).with_index(1) do |page_requests, page|
        write_static_page(path, page, page_requests)
      end
      head :ok
    end

    def write_static_page(path, page, requests)
      @requests = requests
      @page = page
      File.write path.join("#{page}.html"), render_to_string(layout: false)
    end

    def static_page_size
      (params[:per_page].presence || 20).to_i
    end

    def clear_static_pages
      Rails.root.join(Settings::Client.resources_overview_path).tap do |path|
        FileUtils.mkdir_p path
        FileUtils.rm_rf path.glob('*.html')
      end
    end
  end
end
