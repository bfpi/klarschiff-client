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
    @file_name = 'werbung'
    render :api
  end

  def usage
    @file_name = 'nutzungsbedingungen'
    render :api
  end

  def requests
    @page_number = params[:page].to_i || 1
  end

  def contact
    @file_name = 'contact'
    render :api
  end

  def news
    @file_name = 'news'
    render :api
  end

  def finance
    @file_name = 'finance'
    render :api
  end
end
