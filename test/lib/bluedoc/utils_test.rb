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
end
