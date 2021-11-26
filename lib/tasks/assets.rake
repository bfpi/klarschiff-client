# frozen_string_literal: true

namespace :assets do
  desc 'Import external libs configured in config/libs.yml as assets to lib/assets'
  task libs: :environment do
    puts 'Importing external libs configured in config/libs.yml as assets to lib/assets ...'
    require 'open-uri'
    proxy = ENV['HTTP_PROXY'] || ENV['http_proxy'] # Workaround for open-uri https-proxy problem
    config = YAML.safe_load(File.new(Rails.root.join('config/libs.yml'))).with_indifferent_access
    versions = config[:versions]
    config.slice(:javascripts, :stylesheets).each do |folder, targets|
      path_name = Rails.root.join('lib', 'assets', folder)
      FileUtils.mkdir_p path_name unless Dir.exist?(path_name)
      targets.each do |name, src|
        File.open(path_name.join(name), 'wb') do |file|
          file << URI.parse(ERB.new(src).result(binding)).open(proxy: proxy).read
        end
      end
    end
  end

  Rake::Task[:precompile].enhance [:libs]
end
