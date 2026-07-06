# frozen_string_literal: true

class StaticsController < ApplicationController
  def api
    @file_name = 'api'
  end

  def help
    @file_name = 'hilfe'
    render :api
  end

  def imprint
    @file_name = 'impressum'
    render :api
  end

  def privacy
    @file_name = 'datenschutz'
    render :api
  end

  def promotion
    return head(:not_found) unless Settings::StaticPage.promotion
    @file_name = 'werbung'
    render :api
  end

  def usage
    @file_name = 'nutzungsbedingungen'
    render :api
  end

  def requests
    @page_number = params[:page].to_i
  end

  def contact
    return head(:not_found) unless Settings::StaticPage.contact
    @file_name = 'contact'
    render :api
  end

  def news
    return head(:not_found) unless Settings::StaticPage.news
    @file_name = 'news'
    render :api
  end

  def participation
    return head(:not_found) unless Settings::StaticPage.participation
    @file_name = 'participation'
    render :api
  end
end
