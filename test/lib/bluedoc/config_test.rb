# frozen_string_literal: true

require "test_helper"

class BlueDoc::ConfigTest < ActiveSupport::TestCase
  test "Rails.application.config.action_mailer" do
    assert_equal :test, Rails.application.config.action_mailer.delivery_method

    mailer_options = {
      foo: "aaa",
      bar: "bbb"
    }
    Setting.stub(:mailer_option_hash, mailer_options) do
      assert_equal(mailer_options, Rails.application.config.action_mailer.smtp_settings)
    end

    Setting.stub(:host, "http://bluedoc-test.com") do
      assert_equal({ host: "http://bluedoc-test.com" }, Rails.application.config.action_mailer.default_url_options)
    end
  end

  test "Devise.mailer_sender" do
    Setting.stub(:mailer_from, "Foo@bar.com") do
      assert_equal "BlueDoc <Foo@bar.com>", Devise.mailer_sender
    end
    Setting.stub(:mailer_from, "aaa@bbb.com") do
      assert_equal "BlueDoc <aaa@bbb.com>", Devise.mailer_sender
    end
  end

  test "Devise.omniauth_configs" do
    ldap_options = {
      host: "ldap host",
      foo: "aaa",
      bar: "bbb"
    }

    Setting.stub(:omniauth_google_client_id, "google") do
      Setting.stub(:omniauth_google_client_secret, "google secret") do
        Setting.stub(:omniauth_github_client_id, "github") do
          Setting.stub(:omniauth_github_client_secret, "github secret") do
            Setting.stub(:omniauth_gitlab_client_id, "gitlab") do
              Setting.stub(:omniauth_gitlab_client_secret, "gitlab secret") do
                Setting.stub(:omniauth_gitlab_api_prefix, "gitlab prefix") do
                  Setting.stub(:ldap_option_hash, ldap_options) do
                    configs = Devise.omniauth_configs
                    assert_not_nil configs

                    auth_config = configs[:google_oauth2]
                    assert_kind_of Devise::OmniAuth::Config, auth_config
                    assert_equal :google_oauth2, auth_config.strategy_name
                    assert_equal ["google", "google secret"], auth_config.args

                    auth_config = configs[:github]
                    assert_kind_of Devise::OmniAuth::Config, auth_config
                    assert_equal :github, auth_config.strategy_name
                    assert_equal ["github", "github secret"], auth_config.args

                    auth_config = configs[:gitlab]
                    assert_kind_of Devise::OmniAuth::Config, auth_config
                    assert_equal :gitlab, auth_config.strategy_name
                    assert_equal ["gitlab", "gitlab secret", client_options: { site: "gitlab prefix" }], auth_config.args

                    auth_config = configs[:gitlab]
                    assert_kind_of Devise::OmniAuth::Config, auth_config
                    assert_equal :gitlab, auth_config.strategy_name
                    assert_equal ["gitlab", "gitlab secret", client_options: { site: "gitlab prefix" }], auth_config.args

                    auth_config = configs[:ldap]
                    assert_kind_of Devise::OmniAuth::Config, auth_config
                    assert_equal :ldap, auth_config.strategy_name
                    assert_equal [ldap_options], auth_config.args
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  test "ApplicationMailer.default_url_options" do
    assert_equal({ host: Setting.host }, ApplicationMailer.default_url_options)
  end
end