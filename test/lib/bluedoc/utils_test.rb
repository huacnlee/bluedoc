# frozen_string_literal: true

require "test_helper"

class BlueDoc::UtilsTest < ActionView::TestCase
  test "omniauth_camelize" do
    assert_equal "GitHub", BlueDoc::Utils.omniauth_camelize("github")
    assert_equal "GitHub", BlueDoc::Utils.omniauth_camelize(:github)
    assert_equal "GitLab", BlueDoc::Utils.omniauth_camelize("gitlab")
    assert_equal "Google", BlueDoc::Utils.omniauth_camelize("google_oauth2")
    assert_equal "Google", BlueDoc::Utils.omniauth_camelize(:google_oauth2)
    assert_equal Setting.ldap_name, BlueDoc::Utils.omniauth_camelize("ldap")
  end

  test "random_color" do
    20.times do
      color = BlueDoc::Utils.random_color
      assert_equal true, color.start_with?("#")
      assert_equal true, BlueDoc::Utils.valid_color?(color)
    end
  end

  test "valid_color?" do
    assert_equal true, BlueDoc::Utils.valid_color?("#FA01D0")
    assert_equal true, BlueDoc::Utils.valid_color?("#9912EB")
    assert_equal true, BlueDoc::Utils.valid_color?("#000000")
    assert_equal true, BlueDoc::Utils.valid_color?("#999")
    assert_equal true, BlueDoc::Utils.valid_color?("#000")
    assert_equal false, BlueDoc::Utils.valid_color?("#BB")
    assert_equal false, BlueDoc::Utils.valid_color?("#BBCC")
    assert_equal false, BlueDoc::Utils.valid_color?("#BBCCII")
    assert_equal false, BlueDoc::Utils.valid_color?("#09*&()")
    assert_equal false, BlueDoc::Utils.valid_color?("#MN92OP")
  end

  test "humanize_name" do
    assert_equal "Huashun Li", BlueDoc::Utils.humanize_name("huashun.li")
    assert_equal "Huacnlee", BlueDoc::Utils.humanize_name("huacnlee")
    assert_equal "Hua Shun Li", BlueDoc::Utils.humanize_name("hua.shun.li")
    assert_equal "Jason Lee", BlueDoc::Utils.humanize_name("jason-lee")
  end
end
