source 'https://rubygems.org'
git_source(:github) { |repo| 'https://github.com/#{repo}.git' }

ruby '3.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.8'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'

## Ruby libraries no longer included in Ruby 3.4
gem 'ostruct'
gem 'abbrev'
gem 'mutex_m'
gem 'bigdecimal'
gem 'observer'
gem 'nkf'
gem 'drb'

## GraphQL
source 'https://gems.graphql.pro' do
  gem 'graphql-pro'
end
gem 'graphql', '~>2.5.11'
gem 'graphql-c_parser'
gem 'globalid'
gem 'async'
gem 'apollo_upload_server'
gem 'graphql-metrics'

# JWT and Auth
gem 'pundit'
gem 'bcrypt', '~> 3.1', '>= 3.1.12'
gem 'jwt', '~> 2.5'
gem 'rack-cors'

# Enums
gem 'enumerate_it'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails'
  gem 'rspec-json_expectations'
  gem 'rspec-collection_matchers'
  gem 'annotate'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'solargraph'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
end

