# frozen_string_literal: true

require "test_helper"

class LicenseTest < ActiveSupport::TestCase
  # Generate by booklab-license test/fixtures/license.key
  # pub key in development Rails.root.join(".license-key.pub")
  LICENSE_DATA = <<~DATA
  eyJkYXRhIjoiT3Z3bjBEMU5sd3JnWlV6YTFPWFQrbUp2ZGgwWHowYXAreVFx\nTGs3dTlPa0xtay9sTzNQZVNpeEtQakVCXG5kdkdIeHJQTE43YjY2UDVvd0lF\nT3VaOXVoNE1BL0dLejdydWxtaDFoc29iWFZDT1BCVXpFeTZGNkRwRlFcbnVF\nL3ZVSWROTFRIU291QWh6SzZjWmYwQXFjcXUyY3FxVW1JK25vcjY4ZWVxVFpp\na2lTRnd4elpXem1NMFxubks5Y3FnYy9idnl0bFRYdTQ1M0dNYTFtVU52aEc1\nS1VrR05UWVRLb2dOQUdzejZ6RWJUdWorUjJjNlZOXG5sQm5TakxpaUVBTW11\nT2x0M0crZkRIWmo4VzVMY2s5bFdkeis3UXlWT3lrWXQ2ZCtGR3BXV29KVEZt\nTT1cbiIsImtleSI6InFZVFU0R202elVOalNRNzM4M3ZRblo4TnVCUE5SZDZ6\nNUFlMVBiZ2M0TTNYajl6c0l6NkQyNDV3V2ovcVxubG9vTGUxSkVhWDhEakFL\nTlZzRXI5dXZKQWloZTRuL3YrU1JKTEJ5cG0vQ2U3WDBWNkY4U0t3RC9hSGt4\nXG5oMXJaa3pRTDMzZGMrVzkxL29tYXYxQmNaNDgyTDlVdUQxazlka0lBVDIw\nbEVCMzhwcm1GbHAxTHpIOU9cbk1wejM2RmdmRGhKOFhNU3EwVFc3a05WVkw3\nN3N0cm1kb0VxQmYvMUhDNmtSQW1mbk0xYW5hTm9tM080clxuY2FsNWVjSlBO\nMkFCS25RMTZ6ZmNZYzgwcERYQmtycTI5UGlhUFN2cnlzSzlPODM2RkVDWEQ2\nVC9PanhqXG5TcHpMNzJjMTJVcjZuY1dOWGdQajZMZE00QnlLRWpoM2owYThk\nVmE3eVE9PVxuIiwiaXYiOiJTQzJVeFNuZ1JtQy95M2xnUFBaaEJ3PT1cbiJ9
  DATA

  setup do
    Setting.license = LICENSE_DATA
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
