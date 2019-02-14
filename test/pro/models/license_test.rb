# frozen_string_literal: true

require "test_helper"

class LicenseTest < ActiveSupport::TestCase
  # Generate by booklab-license test/fixtures/license.key
  # pub key in development Rails.root.join(".license-key.pub")
  setup do
    Setting.license = read_file("test.booklab-license")
  end

  test "features" do
    License.stub(:trial?, true) do
      License.stub(:expired?, true) do
        assert_equal false, License.allow_feature?(:soft_delete)
      end
    end

    License.stub(:trial?, true) do
      License.stub(:expired?, false) do
        assert_equal true, License.allow_feature?(:soft_delete)
      end
    end

    License.stub(:trial?, false) do
      assert_equal true, License.allow_feature?(:soft_delete)
    end
  end

  test "base delegate methods" do
    assert_not_nil License.license
    assert_equal true, License.license?
    assert_equal Date.new(2019, 2, 14), License.starts_at
    assert_equal Date.new(2050, 2, 15), License.expires_at
    assert_equal true, License.will_expire?
    assert_equal false, License.expired?
    assert_equal (License.expires_at - Date.today).to_i, License.remaining_days
    assert_equal({ plan: "ulimited", user_limit: 100, trial: true }, License.license.restrictions)
    assert_equal "foo", License.restricted_attr(:foo, default: "foo")
    assert_equal "ulimited", License.restricted_attr(:plan, default: "foo")
    assert_equal 100, License.restricted_attr(:user_limit)
    assert_equal true, License.trial?
  end
end
