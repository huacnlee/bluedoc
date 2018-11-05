# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require 'minitest/autorun'
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
    DatabaseCleaner.clean
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
end

class ActionView::TestCase
  include Devise::Test::IntegrationHelpers
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Groups::SignInHelpers

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
