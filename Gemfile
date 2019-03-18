# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "6.0.0.beta3"
gem "pg"
gem "redis"
gem "redis-objects"
gem "puma", "~> 3.11"
gem "react-rails"

gem "graphql"

gem "sidekiq"

gem "webpacker"
gem "turbolinks"
gem "jbuilder"
gem "kaminari"

gem "aws-sdk-s3", require: false
gem "mini_magick"
gem "image_processing", "~> 1.2"
# validates :avatar, file_size:
gem "file_validators"
gem "twemoji"

gem "bootsnap", ">= 1.1.0", require: false

gem "rails-i18n"
gem "rails-settings-cached"

gem "elasticsearch-model"
gem "elasticsearch-rails"

gem "second_level_cache"
gem "bulk_insert"

gem "devise"
gem "omniauth-google-oauth2"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "cancancan"

gem "activestorage-aliyun"
gem "notifications"
gem "action-store"
gem "exception-track"
gem "status-page"
gem "rucaptcha"

gem "html-pipeline"
gem "html-pipeline-rouge_filter"
gem "commonmarker"
gem "sanitize"

gem "bluedoc-toc"
gem "bluedoc-sml"
gem "bluedoc-license"

gem "wicked_pdf"

gem "pghero"

gem "foreman"

group :development, :test do
  gem "mocha"
  gem "letter_opener"
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails"
  gem "brakeman"
  gem "simplecov"
  gem "codecov"
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "rubocop"
  gem "graphiql-rails"
end

group :test do
  gem "database_cleaner"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
