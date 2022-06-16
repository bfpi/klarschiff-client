namespace :assets do
  desc "Import external libs configured in config/libs.yml as assets to lib/assets"
  task libs: :environment do
    puts 'Importing external libs configured in config/libs.yml as assets to lib/assets ...'
    require 'open-uri'
    proxy = ENV['HTTP_PROXY'] || ENV['http_proxy'] # Workaround for open-uri https-proxy problem
    proxy = "http://#{proxy}" if proxy.present? && !proxy.match(%r{^https?://})
    config = YAML.load(File.new(Rails.root.join('config', 'libs.yml'))).with_indifferent_access
    versions = config[:versions]
    config.slice(:javascripts, :stylesheets).each { |folder, targets|
      path_name = Rails.root.join('lib', 'assets', folder)
      FileUtils.mkdir_p path_name unless Dir.exists?(path_name)
      targets.each { |name, src|
        File.open(path_name.join(name), 'wb') { |file|
          file << URI.parse(ERB.new(src).result(binding)).open(proxy: proxy).read
        }
      }
    }
  end

  Rake::Task[:precompile].enhance [:libs]
end
