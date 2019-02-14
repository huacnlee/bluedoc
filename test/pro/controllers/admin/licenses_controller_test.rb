# frozen_string_literal: true

require "test_helper"

class Admin::LicensesControllerTest < ActionDispatch::IntegrationTest
  LICENSE_DATA = <<~DATA
  eyJkYXRhIjoiT3Z3bjBEMU5sd3JnWlV6YTFPWFQrbUp2ZGgwWHowYXAreVFx\nTGs3dTlPa0xtay9sTzNQZVNpeEtQakVCXG5kdkdIeHJQTE43YjY2UDVvd0lF\nT3VaOXVoNE1BL0dLejdydWxtaDFoc29iWFZDT1BCVXpFeTZGNkRwRlFcbnVF\nL3ZVSWROTFRIU291QWh6SzZjWmYwQXFjcXUyY3FxVW1JK25vcjY4ZWVxVFpp\na2lTRnd4elpXem1NMFxubks5Y3FnYy9idnl0bFRYdTQ1M0dNYTFtVU52aEc1\nS1VrR05UWVRLb2dOQUdzejZ6RWJUdWorUjJjNlZOXG5sQm5TakxpaUVBTW11\nT2x0M0crZkRIWmo4VzVMY2s5bFdkeis3UXlWT3lrWXQ2ZCtGR3BXV29KVEZt\nTT1cbiIsImtleSI6InFZVFU0R202elVOalNRNzM4M3ZRblo4TnVCUE5SZDZ6\nNUFlMVBiZ2M0TTNYajl6c0l6NkQyNDV3V2ovcVxubG9vTGUxSkVhWDhEakFL\nTlZzRXI5dXZKQWloZTRuL3YrU1JKTEJ5cG0vQ2U3WDBWNkY4U0t3RC9hSGt4\nXG5oMXJaa3pRTDMzZGMrVzkxL29tYXYxQmNaNDgyTDlVdUQxazlka0lBVDIw\nbEVCMzhwcm1GbHAxTHpIOU9cbk1wejM2RmdmRGhKOFhNU3EwVFc3a05WVkw3\nN3N0cm1kb0VxQmYvMUhDNmtSQW1mbk0xYW5hTm9tM080clxuY2FsNWVjSlBO\nMkFCS25RMTZ6ZmNZYzgwcERYQmtycTI5UGlhUFN2cnlzSzlPODM2RkVDWEQ2\nVC9PanhqXG5TcHpMNzJjMTJVcjZuY1dOWGdQajZMZE00QnlLRWpoM2owYThk\nVmE3eVE9PVxuIiwiaXYiOiJTQzJVeFNuZ1JtQy95M2xnUFBaaEJ3PT1cbiJ9
  DATA

  setup do
    @user = create(:user)
    sign_in @user
  end

  test "GET /admin/licenses" do
    get "/admin/licenses"
    assert_equal 403, response.status

    sign_in_admin @user

    # No license
    License.stub(:license?, false) do
      get "/admin/licenses"
    end
    assert_equal 200, response.status
    assert_select ".flash.license-no"
    assert_select ".license-details", 0
    assert_select "#license-info" do
      assert_select ".box-header", 0
      assert_select ".box-header .btn", 0
    end
    assert_select ".btn.btn-remove-license", 0

    # License expired
    license = BookLab::License.new
    license.starts_at = Date.new(2019, 2, 14)
    license.expires_at = Date.new(2018, 1, 1)
    license.licensee = {
      "Name" => "Jason Lee",
      "Company" => "BookLab Inc.",
      "Email" => "huacnlee@gmail.com"
    }
    license.restrictions = {
      trial: true,
    }
    License.stub(:license, license) do
      get "/admin/licenses"
      assert_equal true, License.expired?
    end
    assert_equal 200, response.status
    assert_select ".license-expired"
    assert_match /2018-01-01/, response.body

    # Limit expires in next year
    license.expires_at = 1.years.since.to_date
    License.stub(:license, license) do
      assert_equal true, License.license?
      assert_equal true, License.trial?
      get "/admin/licenses"
    end
    assert_equal 200, response.status
    assert_select ".flash.license-will-expire"

    assert_select "form[enctype='multipart/form-data']"
    assert_select ".license-details" do
      assert_select "[data-field=name]", text: "Jason Lee"
      assert_select "[data-field=company]", text: "BookLab Inc."
      assert_select "[data-field=email]", text: "huacnlee@gmail.com"
      assert_select "[data-field=starts_at]", text: "2019-02-14"
      assert_select "[data-field=expires_at]", text: license.expires_at.strftime("%Y-%m-%d")
      assert_select "[data-field=trial]", text: "YES"
    end
    assert_select ".btn.btn-remove-license"
  end

  test "POST /admin/licenses" do
    sign_in_admin @user
    post "/admin/licenses", params: { license: rack_upload_file("blank.txt", "text/plain") }
    assert_redirected_to admin_licenses_path
    assert_equal "", Setting.license

    post "/admin/licenses", params: { license: rack_upload_file("test.booklab-license", "text/plain") }
    assert_redirected_to admin_licenses_path
    assert_equal read_file("test.booklab-license").strip, Setting.license.strip
    assert_equal true, License.license?

    get "/admin/licenses"
    assert_equal 200, response.status
    assert_select ".flash", text: "License was successfully updated, thank you."
  end

  test "DELETE /admin/licenses" do
    sign_in_admin @user
    Setting.license = "Foo bar"
    delete "/admin/licenses"
    assert_redirected_to admin_licenses_path
    assert_equal "", Setting.license

    get admin_licenses_path
    assert_equal 200, response.status
    assert_select ".flash", text: "License was successfully deleted."
  end
end
