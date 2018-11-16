# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
# setup omniauth for test
ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] ||= "fake-client-id"
ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] ||= "fake-client-secret"

require_relative "../config/environment"
require "minitest/autorun"
require "rails/test_help"
require "database_cleaner"
require_relative "./support/groups/sign_in_helpers"

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.orm = :active_record
OmniAuth.config.test_mode = true

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    DatabaseCleaner.start
  end

  teardown do
    Rails.cache.clear
    Current.reset
    DatabaseCleaner.clean
  end

  # Mock Current.xxx to a value
  #
  #   mock_current(user: user, request_id: "aaabbbccc123")
  def mock_current(opts = {})
    opts.each_key do |key|
      Current.send("#{key}=", opts[key])
    end
  end

  def read_file(fname)
    load_file(fname).read
  end

  def load_file(fname)
    File.open(Rails.root.join("test", "factories", fname))
  end

  def assert_html_equal(excepted, html)
    assert_equal excepted.gsub(/>[\s]+</, "><"), html.gsub(/>[\s]+</, "><")
  end

  def assert_tracked_notifications(notify_type, target: nil, actor_id: nil, user_id: nil, meta: nil)
    where_opts = { notify_type: notify_type }
    where_opts[:actor_id] = actor_id
    where_opts[:user_id] = user_id
    where_opts[:target] = target

    assert_equal true, Notification.where(where_opts).count > 0
    if meta
      assert_equal meta, Notification.where(where_opts).last.meta
    end
  end
end

class ActionView::TestCase
  include Devise::Test::IntegrationHelpers
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Groups::SignInHelpers

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  def assert_require_user(&block)
    yield block
    assert_equal 302, response.status
    assert_match /\/account\/sign_in/, response.headers["Location"]
  end

  def assert_signed_in
    get account_settings_path
    assert_equal 200, response.status
    assert_match /Signed in as/, response.body
  end
end
