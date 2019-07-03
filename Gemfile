# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "6.0.0.rc1"
gem "pg"
gem "redis"
gem "redis-objects"
gem "puma", "~> 3.11"
gem "react-rails"

gem "graphql"

gem "sidekiq"

gem "webpacker"
gem "turbolinks"
gem "jbuilder", github: "rails/jbuilder"
gem "kaminari"
gem "awesome_nested_set", github: "huacnlee/awesome_nested_set"
gem "request_store"

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
gem "omniauth-ldap"
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
gem "enumize"

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
  gem "rubocop-rails"
  gem "rubocop-performance"
  gem "graphiql-rails"
end

group :test do
  gem "database_cleaner"
end
