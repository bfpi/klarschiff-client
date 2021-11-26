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
    @file_name = 'werbung'
    render :api
  end

  def usage
    @file_name = 'nutzungsbedingungen'
    render :api
  end
end
