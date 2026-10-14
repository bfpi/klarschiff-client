# frozen_string_literal: true

# Delivers the static pages of the installation from the resources of the overlay
class StaticsController < ApplicationController
  def api
    render_resource 'api'
  end

  def help
    render_resource 'hilfe'
  end

  def imprint
    render_resource 'impressum'
  end

  def privacy
    render_resource 'datenschutz'
  end

  def promotion
    return head(:not_found) unless Settings::StaticPage.promotion

    render_resource 'werbung'
  end

  def usage
    render_resource 'nutzungsbedingungen'
  end

  # Pages of the request list, see Requests::StaticPages
  def requests
    @page_number = params[:page].to_i
    respond_to do |format|
      format.html { render file: Rails.root.join(Settings::Client.resources_overview_path, "#{@page_number}.html") }
      format.js
    end
  end

  def contact
    return head(:not_found) unless Settings::StaticPage.contact

    render_resource 'contact'
  end

  def news
    return head(:not_found) unless Settings::StaticPage.news

    render_resource 'news'
  end

  def participation
    return head(:not_found) unless Settings::StaticPage.participation

    render_resource 'participation'
  end

  private

  def render_resource(file_name)
    @file_name = file_name
    respond_to do |format|
      format.html { render file: Rails.root.join(Settings::Client.resources_path, "#{file_name}.html") }
      format.js { render :api }
    end
  end
end
