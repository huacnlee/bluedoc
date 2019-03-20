# frozen_string_literal: true

class Users::LdapsController < ::ApplicationController
  def new
    check_feature! :ldap_auth

    render "devise/sessions/ldap"
  end
end
