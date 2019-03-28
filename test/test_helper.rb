# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
# setup omniauth for test
ENV["OMNIAUTH_GOOGLE_CLIENT_ID"] ||= "fake-client-id"
ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"] ||= "fake-client-secret"
ENV["LDAP_HOST"] ||= "localhost"

require "simplecov"
if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
SimpleCov.start "rails" do
  add_filter "lib/generators"
end

require_relative "../config/environment"
require "minitest/autorun"
require "mocha/minitest"
require "rails/test_help"
require "database_cleaner"
require_relative "../lib/bluedoc/graphql/integration_test"
require_relative "./support/mock_elastic_search"
require_relative "./support/groups/sign_in_helpers"
require_relative "./support/jobs_test_helper"

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.orm = :active_record
OmniAuth.config.test_mode = true

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    DatabaseCleaner.start
    MockElasticSearch.start
    I18n.locale = "en"
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
    load_file(fname).read.strip
  end

  def load_file(fname)
    File.open(Rails.root.join("test", "factories", fname))
  end

  def assert_html_equal(excepted, html)
    assert_equal excepted.strip.gsub(/>[\s]+</, "><"), html.strip.gsub(/>[\s]+</, "><")
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

  # Mock to allow feature in a block
  # allow_feature(:soft_delete) do
  #   assert_equal true, License.allow_feature?(:soft_delete)
  # end
  def allow_feature(name)
    License.stub(:allow_feature?, true) do
      yield
    end
    # Rails.cache.write("mock/test/allow_features", nil)
  end

  # Assert the block process will check the Pro feature
  def assert_check_feature(&block)
    assert_raise(BlueDoc::FeatureNotAvailableError) do
      yield block

      # Patch for intergration test, if reponse.status == 501, invoke raise error
      raise BlueDoc::FeatureNotAvailableError if response&.status == 501
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
    assert_select "a[href='/account/sign_out']"
  end

  # assert react_component render
  #
  # assert_react_component("HelloWorld") do |props|
  #   assert_equal "Hello world", props[:message]
  # end
  def assert_react_component(name)
    assert_select "div[data-react-class=?]", name do |el|
      props = JSON.parse(el.attr("data-react-props"))
      props.deep_symbolize_keys!

      yield(props) if block_given?
    end
  end

  def assert_no_react_component(name)
    assert_select "div[data-react-class='#{name}']", 0
  end

  # assert_flash rendered
  # assert_flash notice: "Repository was successfully created."
  # assert_flash alert: "Repository was successfully created."
  def assert_flash(flash)
    get "/"
    assert_equal 200, response.status
    flash.each_key do |key|
      type = :success if key == :notice
      type = :error if key == :alert

      assert_select ".notice.notice-#{type}", text: flash[key]
    end
  end

  def rack_upload_file(name, content_type = "text/plain")
    Rack::Test::UploadedFile.new(Rails.root.join("test/factories/#{name}"), content_type)
  end
end

class BlueDoc::GraphQL::IntegrationTest
  include Groups::SignInHelpers
end
