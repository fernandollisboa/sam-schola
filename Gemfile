# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.6'
gem 'sprockets-rails'
gem 'pg', '~> 1.1'
gem 'tailwindcss-rails'
# gem "kredis"
# gem "bcrypt", "~> 3.1.7"
gem 'bootsnap', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
# gem "sassc-rails"

group :development, :test do
  gem 'capybara', '~> 3.39'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.2'
  gem 'ffaker', '~> 2.21'
  gem 'rspec-rails', '~> 6.0'
  gem 'shoulda-matchers', '~> 5.3'
end

group :development do
  gem 'guard-rspec', '~>4.7', require: false
  gem 'rubocop', '~> 1.56', require: false
  gem 'rubocop-capybara', '~> 2.18', require: false
  gem 'rubocop-factory_bot', '~> 2.23', require: false
  gem 'rubocop-performance', '~> 1.18', require: false
  gem 'rubocop-rails', '~> 2.20', require: false
  gem 'rubocop-rspec', '~> 2.23', require: false
  gem 'web-console'
end

group :test do
  gem 'simplecov', '~> 0.22.0', require: false
end

gem "foreman", "~> 0.87.2"
