# frozen_string_literal: true

require "test_helper"

class LicenseTest < ActiveSupport::TestCase
  # Generate by bluedoc-license test/fixtures/license.key
  # pub key in development Rails.root.join(".license-key.pub")
  setup do
    Setting.license = read_file("test.bluedoc-license")
  end

  test "features" do
    License.stub(:license?, false) do
      assert_equal false, License.allow_feature?(:soft_delete)
      assert_equal false, License.allow_feature?(:foo)
    end

    License.stub(:trial?, true) do
      License.stub(:expired?, true) do
        assert_equal false, License.allow_feature?(:soft_delete)
      end
    end

    License.stub(:trial?, true) do
      License.stub(:expired?, false) do
        License.license.stub(:allow_feature?, true) do
          assert_equal true, License.allow_feature?(:soft_delete)
        end
      end
    end

    License.stub(:trial?, false) do
      assert_equal false, License.allow_feature?(:foo)
      License.license.stub(:features, %w[]) do
        assert_equal false, License.allow_feature?(:soft_delete)
        assert_equal false, License.allow_feature?(:reader_list)
      end
    end

    License.stub(:trial?, false) do
      License.license.stub(:features, %w[soft_delete reader_list]) do
        assert_equal false, License.allow_feature?(:foo)

        assert_equal true, License.allow_feature?(:soft_delete)
        assert_equal true, License.allow_feature?(:reader_list)
      end
    end
  end

  test "base delegate methods" do
    assert_not_nil License.license
    assert_equal true, License.license?
    assert_equal Date.new(2019, 2, 14), License.starts_at
    assert_equal Date.new(2520, 2, 14), License.expires_at
    assert_equal true, License.will_expire?
    assert_equal false, License.expired?
    assert_equal (License.expires_at - Date.today).to_i, License.remaining_days
    assert_equal({ plan: "ultimate", users_limit: 1000000, trial: true }, License.license.restrictions)
    assert_equal "foo", License.restricted_attr(:foo, default: "foo")
    assert_equal "ultimate", License.restricted_attr(:plan, default: "foo")
    assert_equal true, License.trial?
    assert_equal %w[soft_delete reader_list export_pdf export_archive limit_user_emails], License.features
    assert_equal true, License.allow_feature?(:soft_delete)
    assert_equal false, License.allow_feature?(:soft_delete1)
  end

  test "update" do
    old_license = Setting.license
    License.update("foo")
    assert_equal "foo", Setting.license
    assert_nil License.license

    License.update(old_license)
  end

  test "users_limit" do
    assert_equal License.restricted_attr(:users_limit, default: 0), License.users_limit
  end

  test "current_active_users_count" do
    create_list(:user, 3)
    create_list(:group, 3)
    assert_equal User.unscoped.where(type: "User").where("deleted_at is null").count - 2, License.current_active_users_count
  end

  test "check_users_limit!" do
    assert_equal false, License.check_users_limit!

    License.stub(:current_active_users_count, 21) do
      License.stub(:restricted_attr, 30) do
        assert_equal false, License.check_users_limit!
      end
      License.stub(:restricted_attr, 0) do
        assert_equal false, License.check_users_limit!
      end
      License.stub(:restricted_attr, 5) do
        assert_raise(BlueDoc::UsersLimitError) do |ex|
          License.check_users_limit!
        end
      end
    end
  end
end
