# frozen_string_literal: true

class Users::LdapsController < ::ApplicationController
  def new
    render "devise/sessions/ldap"
  end
end
