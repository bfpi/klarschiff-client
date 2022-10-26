class StaticsController < ApplicationController
  def api
  end

  def help
    render :hilfe
  end

  def imprint
    render :impressum
  end

  def privacy
    render :datenschutz
  end

  def promotion
    render :werbung
  end

  def usage
    render :nutzungsbedingungen
  end
end
