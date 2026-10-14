# frozen_string_literal: true

require 'test_helper'

class StaticsControllerTest < ActionDispatch::IntegrationTest
  PAGE = '<h1 class="help">Hilfe &amp; Kontakt</h1>'

  def with_resources(file, setting: :resources_path, &)
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, file), PAGE)
      Settings::Client.stub(setting, "#{dir}/", &)
    end
  end

  test 'help renders the page of the installation in the layout' do
    with_resources('hilfe.html') { get '/static/help' }

    assert_response :success
    assert_includes response.body, PAGE
    assert_includes response.body, '</html>'
  end

  test 'help renders the page of the installation as js' do
    with_resources('hilfe.html') { get '/static/help', xhr: true }

    assert_includes response.body, "$('.static-overlay').show()"
    assert_includes response.body, ActionController::Base.helpers.escape_javascript(PAGE)
  end

  test 'requests renders a page of the request list' do
    with_resources('2.html', setting: :resources_overview_path) { get '/static/requests/2' }

    assert_response :success
    assert_includes response.body, PAGE
  end

  test 'requests renders a page of the request list as js' do
    with_resources('2.html', setting: :resources_overview_path) { get '/static/requests/2', xhr: true }

    assert_includes response.body, ActionController::Base.helpers.escape_javascript(PAGE)
  end

  test 'optional pages are not found unless enabled' do
    get '/static/promotion'

    assert_response :not_found
  end
end
