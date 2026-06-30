# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 4.0.5'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.3'
# Use Puma as the app server
gem 'activeresource'

gem 'puma', '~> 8.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem 'solid_cable'
# gem 'solid_cache'
# gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: :mri, require: 'debug/prelude'

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  gem 'pronto-rubocop', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'

  gem 'erb_lint', require: false

  gem 'minitest'
  gem 'minitest-mock'

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem 'bundler-audit', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # gem 'listen', '~> 3.2'
  # gem 'web-console', '>= 3.3.0'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'closure-compiler'
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'bootstrap', '~> 5.1.3' # CSS variable usage in v5.2.x is incomplete until Bootstrap 6

# Use jquery as the JavaScript library
gem 'jquery-form-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'

gem 'font-awesome-rails'
gem 'net-ldap'
gem 'oj'
gem 'oj_mimic_json'
gem 'rails-i18n'
gem 'responders'

gem 'device_detector'
