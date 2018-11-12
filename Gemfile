# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails"
gem "pg"
gem "redis"
gem "puma", "~> 3.11"

gem "sidekiq"

gem "webpacker", ">= 4.0.x", github: "rails/webpacker"
gem "turbolinks"
gem "jbuilder"
gem "kaminari"

gem "aws-sdk-s3", require: false
gem "mini_magick"
# validates :avatar, file_size:
gem "file_validators"
gem "letter_avatar"

gem "bootsnap", ">= 1.1.0", require: false

gem "rails-i18n"
gem "rails-settings-cached"

gem "pg_search", github: "Casecommons/pg_search"
gem 'cppjieba_rb', require: false

gem "second_level_cache"

gem "bulk_insert"

gem "devise"
gem "omniauth-google-oauth2"
gem "cancancan"

gem "activestorage-aliyun"
gem "notifications"
gem "action-store"
gem "actiontext", github: "rails/actiontext", require: "action_text"
gem "exception-track"

gem "html-pipeline"
gem "html-pipeline-rouge_filter"
gem "redcarpet"
gem "sanitize"

gem "octicons_helper"

gem "booklab-toc"

group :development, :test do
  gem "letter_opener"
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails"
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "rubocop"
end

group :test do
  gem "database_cleaner"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
