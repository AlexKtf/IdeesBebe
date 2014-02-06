source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>=4.0.0'
gem 'devise'
gem 'cancan'
gem 'omniauth-facebook'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'rails_12factor', group: :production
gem 'unicorn'
gem 'delayed_job_active_record'

# Email
gem 'mandrill-rails'
gem 'email_reply_parser'

# Upload
gem 'cloudinary'
gem 'carrierwave'
gem 'mini_magick'

# CSS
gem 'sass-rails', '~> 4.0.0'
gem 'haml-rails'
gem 'simple_form'

# JS
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'

gem 'coveralls', require: false

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do

  gem 'timecop'
  gem 'annotate', ">=2.6.0"
  gem 'bullet'
  gem "better_errors"
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 2.0'
  gem "factory_girl_rails", "~> 4.0"
  gem 'capybara', :git => 'git://github.com/jnicklas/capybara.git'
  gem 'database_cleaner'
  gem 'selenium-webdriver', '~> 2.35.1'
end

ruby '2.0.0'
